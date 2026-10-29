#Requires -Version 5.1
<#
.SYNOPSIS
  Find work items with simple filters or a WIQL query, and list them as a Markdown table. Read-only.
.EXAMPLE
  ./Find-WorkItems.ps1 -Type 'User Story' -State New,Active -Iteration current
.EXAMPLE
  ./Find-WorkItems.ps1 -Type Bug -Tag regression -Top 50
.EXAMPLE
  ./Find-WorkItems.ps1 -TitleContains 'paystub'
.EXAMPLE
  ./Find-WorkItems.ps1 -Wiql "SELECT [System.Id] FROM WorkItems WHERE [System.TeamProject] = @project AND [System.ChangedDate] >= @today - 7"
#>
[CmdletBinding()]
param(
    [string]$Wiql,
    [string[]]$Type,
    [string[]]$State,
    [string]$Iteration,      # 'current' or a full iteration path
    [string]$AreaPath,       # matches the path and everything under it
    [string]$AssignedTo,     # '@Me' or a display name
    [string]$Tag,
    [string]$TitleContains,
    [int]$ParentId,
    [int]$Top,
    [switch]$Json
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'AdoCommon.psm1') -Force
$cfg = Get-AdoConfig

function Quote([string]$v) { "'" + ($v -replace "'", "''") + "'" }

$limit = if ($Top -gt 0) { [Math]::Min($Top, [int]$cfg.maxResults) } else { [int]$cfg.maxResults }
$scope = 'Project'

if (-not $Wiql) {
    $where = New-Object System.Collections.Generic.List[string]
    $where.Add('[System.TeamProject] = @project')
    if ($Type) { $where.Add('[System.WorkItemType] IN (' + (($Type | ForEach-Object { Quote $_ }) -join ', ') + ')') }
    if ($State) { $where.Add('[System.State] IN (' + (($State | ForEach-Object { Quote $_ }) -join ', ') + ')') }
    if ($Iteration -eq 'current') { $where.Add('[System.IterationPath] = @CurrentIteration'); $scope = 'Team' }
    elseif ($Iteration) { $where.Add("[System.IterationPath] UNDER $(Quote $Iteration)") }
    if ($AreaPath) { $where.Add("[System.AreaPath] UNDER $(Quote $AreaPath)") }
    if ($AssignedTo -eq '@Me') { $where.Add('[System.AssignedTo] = @Me') }
    elseif ($AssignedTo) { $where.Add("[System.AssignedTo] = $(Quote $AssignedTo)") }
    if ($Tag) { $where.Add("[System.Tags] CONTAINS $(Quote $Tag)") }
    if ($TitleContains) { $where.Add("[System.Title] CONTAINS $(Quote $TitleContains)") }
    if ($ParentId -gt 0) { $where.Add("[System.Parent] = $ParentId") }
    $Wiql = "SELECT [System.Id] FROM WorkItems WHERE $($where -join ' AND ') ORDER BY [Microsoft.VSTS.Common.Priority] ASC, [System.ChangedDate] DESC"
}
elseif ($Wiql -match '@CurrentIteration') { $scope = 'Team' }

if ($Wiql -notmatch '^\s*SELECT\s') { throw 'Only SELECT queries are supported.' }

$result = Invoke-AdoApi -Method POST -Path '_apis/wit/wiql' -Query @{ '$top' = $limit } -Body @{ query = $Wiql } -Scope $scope

$ids = @()
if ($result.PSObject.Properties['workItems'] -and $result.workItems) { $ids = @($result.workItems | ForEach-Object { [int]$_.id }) }
elseif ($result.PSObject.Properties['workItemRelations'] -and $result.workItemRelations) {
    $ids = @($result.workItemRelations | ForEach-Object { if ($_.target) { [int]$_.target.id } } | Select-Object -Unique)
}
if ($ids.Count -eq 0) { Write-Output 'No work items matched.'; Write-Output ''; Write-Output "Query: $Wiql"; return }
if ($ids.Count -gt $limit) { $ids = $ids[0..($limit - 1)] }

$items = @(Get-AdoWorkItemsById -Id $ids)
# keep WIQL order
$byId = @{}; foreach ($wi in $items) { $byId[[int]$wi.id] = $wi }
$ordered = @($ids | Where-Object { $byId.ContainsKey($_) } | ForEach-Object { $byId[$_] })

if ($Json) { ConvertTo-Json -InputObject $ordered -Depth 20; return }

Write-Output "Found $($ordered.Count) work item(s)$(if ($ordered.Count -ge $limit) { " (limited to $limit)" })."
Write-Output ''
Write-Output '| ID | Type | Title | State | Assigned to | Iteration | Pts | Pri | Tags |'
Write-Output '|---|---|---|---|---|---|---|---|---|'
foreach ($wi in $ordered) {
    $iter = [string](Get-AdoField $wi 'System.IterationPath' '')
    $iterShort = ($iter -split '\\')[-1]
    $cells = @(
        "#$($wi.id)",
        (Get-AdoField $wi 'System.WorkItemType'),
        (ConvertTo-AdoMarkdownCell (Get-AdoField $wi 'System.Title') 70),
        (Get-AdoField $wi 'System.State'),
        (Format-AdoIdentity (Get-AdoField $wi 'System.AssignedTo')),
        $iterShort,
        (Get-AdoField $wi 'Microsoft.VSTS.Scheduling.StoryPoints' ''),
        (Get-AdoField $wi 'Microsoft.VSTS.Common.Priority' ''),
        (ConvertTo-AdoMarkdownCell (Get-AdoField $wi 'System.Tags' '') 40)
    )
    Write-Output ('| ' + ($cells -join ' | ') + ' |')
}
Write-Output ''
Write-Output "Query: $Wiql"
