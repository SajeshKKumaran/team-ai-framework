#Requires -Version 5.1
<#
.SYNOPSIS
  Read one or more work items as Markdown: fields, description, acceptance criteria, repro steps,
  test steps, links, and optionally the discussion history. Read-only.
.EXAMPLE
  ./Get-WorkItem.ps1 -Id 1234
.EXAMPLE
  ./Get-WorkItem.ps1 -Id 1234,1235 -IncludeDiscussion
.EXAMPLE
  ./Get-WorkItem.ps1 -Id 1234 -Json      # raw API response, for scripting
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][int[]]$Id,
    [switch]$IncludeDiscussion,
    [switch]$Json
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'AdoCommon.psm1') -Force

$items = @(Get-AdoWorkItemsById -Id $Id -WithRelations)
if ($Json) { ConvertTo-Json -InputObject $items -Depth 20; return }

$found = @($items | ForEach-Object { [int]$_.id })
foreach ($missing in @($Id | Where-Object { $found -notcontains $_ })) {
    Write-Output "> Work item #$missing was not found or you don't have access to it."
    Write-Output ''
}

foreach ($wi in $items) {
    $type = Get-AdoField $wi 'System.WorkItemType'
    Write-Output "## #$($wi.id) - $(Get-AdoField $wi 'System.Title')"
    Write-Output ''
    Write-Output "| Field | Value |"
    Write-Output "|---|---|"
    $rows = [ordered]@{
        'Type'        = $type
        'State'       = Get-AdoField $wi 'System.State'
        'Reason'      = Get-AdoField $wi 'System.Reason'
        'Assigned to' = Format-AdoIdentity (Get-AdoField $wi 'System.AssignedTo')
        'Iteration'   = Get-AdoField $wi 'System.IterationPath'
        'Area'        = Get-AdoField $wi 'System.AreaPath'
        'Priority'    = Get-AdoField $wi 'Microsoft.VSTS.Common.Priority'
        'Severity'    = Get-AdoField $wi 'Microsoft.VSTS.Common.Severity'
        'Story points'= Get-AdoField $wi 'Microsoft.VSTS.Scheduling.StoryPoints'
        'Remaining'   = Get-AdoField $wi 'Microsoft.VSTS.Scheduling.RemainingWork'
        'Tags'        = Get-AdoField $wi 'System.Tags'
        'Changed'     = Get-AdoField $wi 'System.ChangedDate'
        'URL'         = Get-AdoWorkItemUrl -Id $wi.id
    }
    foreach ($key in $rows.Keys) {
        if ($null -ne $rows[$key] -and [string]$rows[$key] -ne '') { Write-Output "| $key | $(ConvertTo-AdoMarkdownCell $rows[$key] 200) |" }
    }
    Write-Output ''

    $sections = [ordered]@{
        'Description'         = 'System.Description'
        'Acceptance criteria' = 'Microsoft.VSTS.Common.AcceptanceCriteria'
        'Repro steps'         = 'Microsoft.VSTS.TCM.ReproSteps'
        'System info'         = 'Microsoft.VSTS.TCM.SystemInfo'
    }
    foreach ($title in $sections.Keys) {
        $text = ConvertFrom-AdoHtml (Get-AdoField $wi $sections[$title])
        if ($text) { Write-Output "### $title"; Write-Output ''; Write-Output $text; Write-Output '' }
    }
    if ($type -eq 'User Story' -and -not (Get-AdoField $wi 'Microsoft.VSTS.Common.AcceptanceCriteria')) {
        Write-Output '> Note: this story has no acceptance criteria.'
        Write-Output ''
    }

    $steps = @(ConvertFrom-AdoTestStepsXml (Get-AdoField $wi 'Microsoft.VSTS.TCM.Steps'))
    if ($steps.Count -gt 0) {
        Write-Output '### Test steps'
        Write-Output ''
        Write-Output '| # | Action | Expected result |'
        Write-Output '|---|---|---|'
        foreach ($s in $steps) { Write-Output "| $($s.Step) | $(ConvertTo-AdoMarkdownCell $s.Action 300) | $(ConvertTo-AdoMarkdownCell $s.Expected 300) |" }
        Write-Output ''
    }

    $relations = if ($wi.PSObject.Properties['relations'] -and $wi.relations) { @($wi.relations) } else { @() }
    if ($relations.Count -gt 0) {
        Write-Output '### Links'
        Write-Output ''
        foreach ($rel in $relations) {
            $name = if ($rel.PSObject.Properties['attributes'] -and $rel.attributes.PSObject.Properties['name']) { $rel.attributes.name } else { $rel.rel }
            $m = [regex]::Match([string]$rel.url, '/workItems/(\d+)$', 'IgnoreCase')
            $target = if ($m.Success) { "#$($m.Groups[1].Value)" } else { [string]$rel.url }
            Write-Output "- $name : $target"
        }
        Write-Output ''
    }

    if ($IncludeDiscussion) {
        $updates = Invoke-AdoApi -Method GET -Path "_apis/wit/workitems/$($wi.id)/updates" -Query @{ '$top' = 200 } -Scope Collection
        $comments = @()
        foreach ($u in @($updates.value)) {
            if ($u.PSObject.Properties['fields'] -and $u.fields -and $u.fields.PSObject.Properties['System.History']) {
                $when = if ($u.fields.PSObject.Properties['System.ChangedDate']) { $u.fields.'System.ChangedDate'.newValue } else { '' }
                $comments += [pscustomobject]@{ By = Format-AdoIdentity $u.revisedBy; When = $when; Text = ConvertFrom-AdoHtml $u.fields.'System.History'.newValue }
            }
        }
        if ($comments.Count -gt 0) {
            Write-Output '### Discussion'
            Write-Output ''
            foreach ($c in $comments) { Write-Output "- **$($c.By)** ($($c.When)): $($c.Text -replace "`n", ' ')" }
            Write-Output ''
        }
    }
}
