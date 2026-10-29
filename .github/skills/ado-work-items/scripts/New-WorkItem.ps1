#Requires -Version 5.1
<#
.SYNOPSIS
  Create work items. PREVIEW BY DEFAULT: without -Apply nothing is written.
  Every created item gets the AI tag from ado.config.json (default "ai-assisted").

.DESCRIPTION
  Single item:  pass -Type and -Title (plus optional fields).
  Many items:   pass -InputFile with a JSON array (or a single object) like:
    [
      {
        "type": "User Story",
        "title": "Employee downloads a paystub as PDF",
        "description": "Markdown text",
        "acceptanceCriteria": "Markdown text (Gherkin is fine)",
        "parentId": 1200,
        "tags": ["payroll"],
        "fields": { "Microsoft.VSTS.Common.Priority": 2, "Microsoft.VSTS.Scheduling.StoryPoints": 3 }
      }
    ]

.EXAMPLE
  ./New-WorkItem.ps1 -Type Task -Title 'Add PDF export endpoint' -ParentId 1234
.EXAMPLE
  ./New-WorkItem.ps1 -InputFile ./.ai/drafts/stories-1200.json            # preview
  ./New-WorkItem.ps1 -InputFile ./.ai/drafts/stories-1200.json -Apply     # after the user approves
#>
[CmdletBinding(DefaultParameterSetName = 'Single')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Single')][string]$Type,
    [Parameter(Mandatory, ParameterSetName = 'Single')][string]$Title,
    [Parameter(ParameterSetName = 'Single')][string]$Description,
    [Parameter(ParameterSetName = 'Single')][string]$AcceptanceCriteria,
    [Parameter(ParameterSetName = 'Single')][int]$ParentId,
    [Parameter(ParameterSetName = 'Single')][string[]]$Tags,
    [Parameter(ParameterSetName = 'Single')][hashtable]$Fields,
    [Parameter(Mandatory, ParameterSetName = 'File')][string]$InputFile,
    [switch]$Apply
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'AdoCommon.psm1') -Force
$cfg = Get-AdoConfig

function Get-Prop($obj, [string]$name) { if ($obj -and $obj.PSObject.Properties[$name]) { return $obj.$name } return $null }

# Normalize input into a list of drafts
$drafts = @()
if ($PSCmdlet.ParameterSetName -eq 'File') {
    if (-not (Test-Path -LiteralPath $InputFile)) { throw "Input file not found: $InputFile" }
    $data = Get-Content -LiteralPath $InputFile -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($d in @($data)) {
        $f = @{}
        $fieldsObj = Get-Prop $d 'fields'
        if ($fieldsObj) { foreach ($p in $fieldsObj.PSObject.Properties) { $f[$p.Name] = $p.Value } }
        $drafts += [pscustomobject]@{
            Type = [string](Get-Prop $d 'type'); Title = [string](Get-Prop $d 'title')
            Description = [string](Get-Prop $d 'description'); AcceptanceCriteria = [string](Get-Prop $d 'acceptanceCriteria')
            ParentId = [int](Get-Prop $d 'parentId'); Tags = @(Get-Prop $d 'tags' | Where-Object { $_ }); Fields = $f
        }
    }
}
else {
    $drafts += [pscustomobject]@{
        Type = $Type; Title = $Title; Description = $Description; AcceptanceCriteria = $AcceptanceCriteria
        ParentId = $ParentId; Tags = @($Tags | Where-Object { $_ }); Fields = $(if ($Fields) { $Fields } else { @{} })
    }
}

if ($drafts.Count -eq 0) { throw 'Nothing to create.' }
if ($drafts.Count -gt [int]$cfg.maxItemsPerWrite) {
    throw "Guardrail: $($drafts.Count) items exceeds maxItemsPerWrite ($($cfg.maxItemsPerWrite)). Split the file into smaller batches."
}

# Validate everything before writing anything
$plans = @()
$n = 0
foreach ($d in $drafts) {
    $n++
    if ([string]::IsNullOrWhiteSpace($d.Type) -or [string]::IsNullOrWhiteSpace($d.Title)) { throw "Item $n is missing 'type' or 'title'." }
    Assert-AdoCreatableType $d.Type

    $ops = New-Object System.Collections.Generic.List[object]
    $ops.Add(@{ op = 'add'; path = '/fields/System.Title'; value = $d.Title.Trim() })
    if ($d.Description) { $ops.Add(@{ op = 'add'; path = '/fields/System.Description'; value = (ConvertTo-AdoHtml $d.Description) }) }
    if ($d.AcceptanceCriteria) {
        $acField = 'Microsoft.VSTS.Common.AcceptanceCriteria'
        Assert-AdoWritableField $acField
        $ops.Add(@{ op = 'add'; path = "/fields/$acField"; value = (ConvertTo-AdoHtml $d.AcceptanceCriteria) })
    }
    foreach ($key in $d.Fields.Keys) {
        if (@('System.Title', 'System.Description', 'System.Tags') -contains $key) { continue }
        Assert-AdoWritableField $key
        if ($key -eq 'System.State') { Assert-AdoStateAllowed ([string]$d.Fields[$key]) }
        $value = $d.Fields[$key]
        if (@('Microsoft.VSTS.TCM.ReproSteps', 'Microsoft.VSTS.TCM.SystemInfo', 'System.History') -contains $key) { $value = ConvertTo-AdoHtml ([string]$value) }
        $ops.Add(@{ op = 'add'; path = "/fields/$key"; value = $value })
    }
    $ops.Add(@{ op = 'add'; path = '/fields/System.Tags'; value = (Merge-AdoTags -Existing '' -Add $d.Tags) })
    if ($d.ParentId -gt 0) {
        $ops.Add(@{ op = 'add'; path = '/relations/-'; value = @{ rel = 'System.LinkTypes.Hierarchy-Reverse'; url = "$($cfg.collectionUrl)/_apis/wit/workItems/$($d.ParentId)" } })
    }
    $plans += [pscustomobject]@{ Draft = $d; Ops = $ops.ToArray() }
}

if (-not $Apply) {
    Write-AdoPreviewBanner -Count $plans.Count -What "create work items in project '$($cfg.project)'"
    Write-Output '| # | Type | Title | Parent | Extra fields | Tags |'
    Write-Output '|---|---|---|---|---|---|'
    $i = 0
    foreach ($p in $plans) {
        $i++
        $extra = (@($p.Draft.Fields.Keys) | ForEach-Object { ($_ -split '\.')[-1] + '=' + (ConvertTo-AdoMarkdownCell $p.Draft.Fields[$_] 20) }) -join ', '
        if ($p.Draft.AcceptanceCriteria) { $extra = (@('AcceptanceCriteria', $extra) | Where-Object { $_ }) -join ', ' }
        $parent = if ($p.Draft.ParentId -gt 0) { "#$($p.Draft.ParentId)" } else { '' }
        $tags = ($p.Ops | Where-Object { $_.path -eq '/fields/System.Tags' }).value
        Write-Output "| $i | $($p.Draft.Type) | $(ConvertTo-AdoMarkdownCell $p.Draft.Title 70) | $parent | $extra | $tags |"
    }
    return
}

Write-Output "Creating $($plans.Count) work item(s) in '$($cfg.project)'..."
foreach ($p in $plans) {
    $typeSegment = '$' + [uri]::EscapeDataString($p.Draft.Type)
    $created = Invoke-AdoApi -Method POST -Path "_apis/wit/workitems/$typeSegment" -Body $p.Ops -ContentType 'application/json-patch+json'
    Write-AdoAudit -Action 'create' -Detail "#$($created.id) [$($p.Draft.Type)] $($p.Draft.Title)"
    Write-Output "- Created #$($created.id) $($p.Draft.Type): $($p.Draft.Title)  $(Get-AdoWorkItemUrl -Id $created.id)"
}
