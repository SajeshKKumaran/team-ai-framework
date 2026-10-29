#Requires -Version 5.1
<#
.SYNOPSIS
  Create Azure DevOps Test Case work items (with steps) from a JSON file produced by the test-design skill,
  and link each one to the story it tests. PREVIEW BY DEFAULT: nothing is written without -Apply.

.DESCRIPTION
  Input file format:
    {
      "storyId": 1234,
      "testCases": [
        {
          "title": "Download paystub - employee with one pay period",
          "priority": 1,
          "tags": ["smoke", "regression-candidate"],
          "preconditions": "Employee 'Test User A' has a processed pay period.",
          "steps": [
            { "action": "Sign in as Test User A", "expected": "" },
            { "action": "Open Pay > Paystubs and select the latest period", "expected": "Paystub details are shown" },
            { "action": "Select Download PDF", "expected": "A PDF named Paystub_<period>.pdf downloads" }
          ]
        }
      ]
    }

  Tip: in Azure Test Plans, a requirement-based suite for the story picks up test cases linked this way.

.EXAMPLE
  ./New-TestCases.ps1 -InputFile ./.ai/drafts/1234-testcases.json           # preview
  ./New-TestCases.ps1 -InputFile ./.ai/drafts/1234-testcases.json -Apply    # after the user approves
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$InputFile,
    [int]$StoryId,
    [switch]$Apply
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'AdoCommon.psm1') -Force
$cfg = Get-AdoConfig

function Get-Prop($obj, [string]$name) { if ($obj -and $obj.PSObject.Properties[$name]) { return $obj.$name } return $null }

if (-not (Test-Path -LiteralPath $InputFile)) { throw "Input file not found: $InputFile" }
$data = Get-Content -LiteralPath $InputFile -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $StoryId) { $StoryId = [int](Get-Prop $data 'storyId') }
$cases = @(Get-Prop $data 'testCases')
if ($cases.Count -eq 0) { throw "No testCases found in $InputFile." }
if ($cases.Count -gt [int]$cfg.maxItemsPerWrite) { throw "Guardrail: $($cases.Count) test cases exceeds maxItemsPerWrite ($($cfg.maxItemsPerWrite)). Split the file." }

Assert-AdoCreatableType 'Test Case'
Assert-AdoWritableField 'Microsoft.VSTS.TCM.Steps'

$story = $null
if ($StoryId -gt 0) {
    $found = @(Get-AdoWorkItemsById -Id $StoryId)
    if ($found.Count -eq 0) { throw "Story #$StoryId was not found or you don't have access to it." }
    $story = $found[0]
}

$plans = @()
$n = 0
foreach ($tc in $cases) {
    $n++
    $title = [string](Get-Prop $tc 'title')
    $steps = @(Get-Prop $tc 'steps')
    if (-not $title) { throw "Test case $n has no title." }
    if ($steps.Count -eq 0) { throw "Test case $n ('$title') has no steps." }

    $ops = New-Object System.Collections.Generic.List[object]
    $ops.Add(@{ op = 'add'; path = '/fields/System.Title'; value = $title })
    $ops.Add(@{ op = 'add'; path = '/fields/Microsoft.VSTS.TCM.Steps'; value = (ConvertTo-AdoTestStepsXml -Steps $steps) })
    $pre = [string](Get-Prop $tc 'preconditions')
    if ($pre) { $ops.Add(@{ op = 'add'; path = '/fields/System.Description'; value = (ConvertTo-AdoHtml "**Preconditions**`n$pre") }) }
    $priority = Get-Prop $tc 'priority'
    if ($priority) { $ops.Add(@{ op = 'add'; path = '/fields/Microsoft.VSTS.Common.Priority'; value = [int]$priority }) }
    if ($story) {
        foreach ($f in 'System.AreaPath', 'System.IterationPath') {
            $v = Get-AdoField $story $f
            if ($v) { $ops.Add(@{ op = 'add'; path = "/fields/$f"; value = $v }) }
        }
        # Test Case --Tests--> Story (the story shows it as "Tested By")
        $ops.Add(@{ op = 'add'; path = '/relations/-'; value = @{ rel = 'Microsoft.VSTS.Common.TestedBy-Reverse'; url = "$($cfg.collectionUrl)/_apis/wit/workItems/$StoryId" } })
    }
    $ops.Add(@{ op = 'add'; path = '/fields/System.Tags'; value = (Merge-AdoTags -Existing '' -Add @(Get-Prop $tc 'tags' | Where-Object { $_ })) })
    $plans += [pscustomobject]@{ Title = $title; Steps = $steps; Priority = $priority; Ops = $ops.ToArray() }
}

if (-not $Apply) {
    $target = if ($story) { "linked to #$StoryId '$(Get-AdoField $story 'System.Title')'" } else { 'NOT linked to any story (no storyId given)' }
    Write-AdoPreviewBanner -Count $plans.Count -What "create Test Case work items $target"
    $i = 0
    foreach ($p in $plans) {
        $i++
        Write-Output "### $i. $($p.Title)$(if ($p.Priority) { "  (priority $($p.Priority))" })"
        Write-Output ''
        Write-Output '| # | Action | Expected result |'
        Write-Output '|---|---|---|'
        $s = 0
        foreach ($step in $p.Steps) {
            $s++
            $exp = Get-Prop $step 'expected'
            Write-Output "| $s | $(ConvertTo-AdoMarkdownCell $step.action 150) | $(ConvertTo-AdoMarkdownCell $exp 150) |"
        }
        Write-Output ''
    }
    return
}

Write-Output "Creating $($plans.Count) test case(s)..."
$createdIds = @()
foreach ($p in $plans) {
    $created = Invoke-AdoApi -Method POST -Path ('_apis/wit/workitems/$' + [uri]::EscapeDataString('Test Case')) -Body $p.Ops -ContentType 'application/json-patch+json'
    $createdIds += $created.id
    Write-AdoAudit -Action 'create-testcase' -Detail "#$($created.id) $($p.Title)$(if ($StoryId) { " tests #$StoryId" })"
    Write-Output "- Created test case #$($created.id): $($p.Title)"
}
if ($StoryId) { Write-Output "All linked to #$StoryId with a Tests link. Add them to a requirement-based suite for #$StoryId in Test Plans to run them." }
