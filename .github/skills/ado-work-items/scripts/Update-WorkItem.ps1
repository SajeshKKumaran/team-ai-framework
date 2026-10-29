#Requires -Version 5.1
<#
.SYNOPSIS
  Update fields on one work item, add tags, or add a discussion comment.
  PREVIEW BY DEFAULT: shows current vs proposed values. Nothing is written without -Apply.
  Uses optimistic concurrency: if someone changed the item after the preview, the update fails instead of overwriting.

.EXAMPLE
  ./Update-WorkItem.ps1 -Id 1234 -AcceptanceCriteria (Get-Content ./.ai/drafts/1234-ac.md -Raw -Encoding UTF8)
.EXAMPLE
  ./Update-WorkItem.ps1 -Id 1234 -Comment 'Test cases #2001-#2006 created from the acceptance criteria.' -Apply
.EXAMPLE
  ./Update-WorkItem.ps1 -Id 1234 -Fields @{ 'Microsoft.VSTS.Scheduling.StoryPoints' = 5 } -AddTags 'needs-sa-review'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][int]$Id,
    [string]$Title,
    [string]$Description,
    [string]$AcceptanceCriteria,
    [string]$Comment,
    [string[]]$AddTags,
    [hashtable]$Fields,
    [switch]$Apply
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'AdoCommon.psm1') -Force
$cfg = Get-AdoConfig

$current = @(Get-AdoWorkItemsById -Id $Id)
if ($current.Count -eq 0) { throw "Work item #$Id was not found or you don't have access to it." }
$wi = $current[0]

$changes = [ordered]@{}
if ($Title) { $changes['System.Title'] = $Title }
if ($Description) { $changes['System.Description'] = ConvertTo-AdoHtml $Description }
if ($AcceptanceCriteria) { $changes['Microsoft.VSTS.Common.AcceptanceCriteria'] = ConvertTo-AdoHtml $AcceptanceCriteria }
if ($Fields) {
    foreach ($key in $Fields.Keys) {
        $value = $Fields[$key]
        if (@('Microsoft.VSTS.TCM.ReproSteps', 'Microsoft.VSTS.TCM.SystemInfo') -contains $key) { $value = ConvertTo-AdoHtml ([string]$value) }
        $changes[$key] = $value
    }
}
if ($AddTags) { $changes['System.Tags'] = Merge-AdoTags -Existing ([string](Get-AdoField $wi 'System.Tags' '')) -Add $AddTags }
if ($Comment) { $changes['System.History'] = ConvertTo-AdoHtml "$Comment`n`n(drafted with AI assistance)" }

if ($changes.Count -eq 0) { throw 'Nothing to update. Pass at least one of -Title, -Description, -AcceptanceCriteria, -Comment, -AddTags or -Fields.' }

foreach ($key in $changes.Keys) {
    Assert-AdoWritableField $key
    if ($key -eq 'System.State') { Assert-AdoStateAllowed ([string]$changes[$key]) }
}
# Any field change (not just a comment) also marks the item as AI-assisted.
$fieldChanges = @($changes.Keys | Where-Object { $_ -ne 'System.History' })
if ($fieldChanges.Count -gt 0 -and -not $changes.Contains('System.Tags')) {
    $existingTags = [string](Get-AdoField $wi 'System.Tags' '')
    $merged = Merge-AdoTags -Existing $existingTags -Add @()
    if ($merged -ne $existingTags) { $changes['System.Tags'] = $merged }
}

if (-not $Apply) {
    Write-AdoPreviewBanner -Count 1 -What "update #$Id '$(Get-AdoField $wi 'System.Title')' (revision $($wi.rev))"
    Write-Output '| Field | Current | Proposed |'
    Write-Output '|---|---|---|'
    foreach ($key in $changes.Keys) {
        $old = Get-AdoField $wi $key ''
        $oldText = if ($old -is [string] -and $old -match '<[a-z]') { ConvertFrom-AdoHtml $old } else { Format-AdoIdentity $old }
        $newRaw = $changes[$key]
        $newText = if ($newRaw -is [string] -and $newRaw -match '<[a-z]') { ConvertFrom-AdoHtml $newRaw } else { [string]$newRaw }
        if ($key -eq 'System.History') { $oldText = '(new comment)' }
        Write-Output "| $key | $(ConvertTo-AdoMarkdownCell $oldText 120) | $(ConvertTo-AdoMarkdownCell $newText 120) |"
    }
    Write-Output ''
    Write-Output 'Long text values are truncated in this table; show the full proposed text to the user before applying.'
    return
}

$ops = New-Object System.Collections.Generic.List[object]
$ops.Add(@{ op = 'test'; path = '/rev'; value = [int]$wi.rev })
foreach ($key in $changes.Keys) { $ops.Add(@{ op = 'add'; path = "/fields/$key"; value = $changes[$key] }) }

try {
    $updated = Invoke-AdoApi -Method PATCH -Path "_apis/wit/workitems/$Id" -Body $ops.ToArray() -ContentType 'application/json-patch+json' -Scope Collection
}
catch {
    if ($_.Exception.Message -match 'rev|TF26071|conflict') { throw "Work item #$Id changed after the preview. Run the preview again and re-confirm with the user. ($($_.Exception.Message))" }
    throw
}
Write-AdoAudit -Action 'update' -Detail "#$Id fields: $(@($changes.Keys) -join ', ')"
Write-Output "Updated #$Id (now revision $($updated.rev)): $(@($changes.Keys) -join ', ')"
Write-Output (Get-AdoWorkItemUrl -Id $Id)
