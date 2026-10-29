#Requires -Version 5.1
<#
.SYNOPSIS
  Snapshot of a sprint for the team in ado.config.json: dates, items by state and type, work per person,
  blocked items and readiness gaps. Read-only. Used by the sprint-report and sprint-planning-prep skills.
.EXAMPLE
  ./Get-SprintItems.ps1                       # current sprint
.EXAMPLE
  ./Get-SprintItems.ps1 -Timeframe future     # next sprint (for planning prep)
.EXAMPLE
  ./Get-SprintItems.ps1 -IterationPath 'MyProject\Release 3\Sprint 42'
#>
[CmdletBinding()]
param(
    [ValidateSet('current', 'future', 'past')][string]$Timeframe = 'current',
    [string]$IterationPath,
    [switch]$Json
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'AdoCommon.psm1') -Force
$cfg = Get-AdoConfig

function Quote([string]$v) { "'" + ($v -replace "'", "''") + "'" }

# 1. Resolve the iteration
$sprint = $null
$iterations = @((Invoke-AdoApi -Method GET -Path '_apis/work/teamsettings/iterations' -Scope Team).value)
if ($IterationPath) {
    $sprint = $iterations | Where-Object { $_.path -eq $IterationPath } | Select-Object -First 1
    if (-not $sprint) { $sprint = [pscustomobject]@{ name = ($IterationPath -split '\\')[-1]; path = $IterationPath; attributes = $null } }
}
else {
    $candidates = @($iterations | Where-Object { $_.attributes -and $_.attributes.PSObject.Properties['timeFrame'] -and $_.attributes.timeFrame -eq $Timeframe })
    if ($Timeframe -eq 'future') { $candidates = @($candidates | Sort-Object { $_.attributes.startDate }) }
    if ($Timeframe -eq 'past') { $candidates = @($candidates | Sort-Object { $_.attributes.finishDate } -Descending) }
    $sprint = $candidates | Select-Object -First 1
}
if (-not $sprint) { throw "No $Timeframe iteration found for team '$($cfg.team)'. Check the team's sprint settings or pass -IterationPath." }

# 2. Items in the iteration
$wiql = "SELECT [System.Id] FROM WorkItems WHERE [System.TeamProject] = @project AND [System.IterationPath] = $(Quote $sprint.path) AND [System.State] <> 'Removed' ORDER BY [System.WorkItemType] ASC, [System.Id] ASC"
$result = Invoke-AdoApi -Method POST -Path '_apis/wit/wiql' -Body @{ query = $wiql }
$ids = @()
if ($result.workItems) { $ids = @($result.workItems | ForEach-Object { [int]$_.id }) }
$items = if ($ids.Count) { @(Get-AdoWorkItemsById -Id $ids) } else { @() }

if ($Json) { ConvertTo-Json -InputObject ([pscustomobject]@{ iteration = $sprint; workItems = $items }) -Depth 20; return }

# 3. Header
Write-Output "# Sprint snapshot: $($sprint.name)"
Write-Output ''
Write-Output "- Iteration path: $($sprint.path)"
if ($sprint.attributes -and $sprint.attributes.PSObject.Properties['startDate'] -and $sprint.attributes.startDate) {
    $start = [datetime]$sprint.attributes.startDate; $finish = [datetime]$sprint.attributes.finishDate
    $today = (Get-Date).Date
    $workdaysLeft = 0
    for ($d = $today; $d -le $finish.Date; $d = $d.AddDays(1)) { if ($d.DayOfWeek -ne 'Saturday' -and $d.DayOfWeek -ne 'Sunday') { $workdaysLeft++ } }
    Write-Output "- Dates: $($start.ToString('yyyy-MM-dd')) to $($finish.ToString('yyyy-MM-dd'))"
    if ($Timeframe -eq 'current' -and -not $IterationPath) { Write-Output "- Working days left (incl. today, excl. weekends and holidays): $workdaysLeft" }
}
Write-Output "- Snapshot taken: $((Get-Date).ToString('yyyy-MM-dd HH:mm'))"
Write-Output "- Work items: $($items.Count)"
Write-Output ''
if ($items.Count -eq 0) { Write-Output 'No work items in this iteration.'; return }

# 4. Summary by type and state
Write-Output '## By type and state'
Write-Output ''
Write-Output '| Type | State | Count | Story points |'
Write-Output '|---|---|---|---|'
$items | Group-Object { "$(Get-AdoField $_ 'System.WorkItemType')|$(Get-AdoField $_ 'System.State')" } | Sort-Object Name | ForEach-Object {
    $parts = $_.Name -split '\|'
    $pts = ($_.Group | ForEach-Object { [double](Get-AdoField $_ 'Microsoft.VSTS.Scheduling.StoryPoints' 0) } | Measure-Object -Sum).Sum
    Write-Output "| $($parts[0]) | $($parts[1]) | $($_.Count) | $(if ($pts) { $pts } else { '' }) |"
}
Write-Output ''

# 5. Remaining work per person (tasks)
$tasks = @($items | Where-Object { (Get-AdoField $_ 'System.WorkItemType') -eq 'Task' })
if ($tasks.Count) {
    Write-Output '## Remaining task hours by person'
    Write-Output ''
    Write-Output '| Person | Open tasks | Remaining hours |'
    Write-Output '|---|---|---|'
    $tasks | Where-Object { @('Closed', 'Done', 'Removed') -notcontains (Get-AdoField $_ 'System.State') } |
        Group-Object { $n = Format-AdoIdentity (Get-AdoField $_ 'System.AssignedTo'); if ($n) { $n } else { '(unassigned)' } } | Sort-Object Name | ForEach-Object {
            $rem = ($_.Group | ForEach-Object { [double](Get-AdoField $_ 'Microsoft.VSTS.Scheduling.RemainingWork' 0) } | Measure-Object -Sum).Sum
            Write-Output "| $($_.Name) | $($_.Count) | $rem |"
        }
    Write-Output ''
}

# 6. Attention list (one row per item, all reasons)
$attention = New-Object System.Collections.Generic.List[string]
$staleDays = 3
foreach ($wi in $items) {
    $type = Get-AdoField $wi 'System.WorkItemType'
    $state = Get-AdoField $wi 'System.State'
    $tags = [string](Get-AdoField $wi 'System.Tags' '')
    $open = @('Closed', 'Done', 'Removed', 'Resolved') -notcontains $state
    $isStory = @('User Story', 'Product Backlog Item') -contains $type
    $why = New-Object System.Collections.Generic.List[string]
    if ($cfg.blockedTag -and ($tags -split ';\s*') -contains $cfg.blockedTag) { $why.Add("tagged $($cfg.blockedTag)") }
    if ($isStory -and -not (Get-AdoField $wi 'Microsoft.VSTS.Common.AcceptanceCriteria')) { $why.Add('no acceptance criteria') }
    if ($isStory -and $null -eq (Get-AdoField $wi 'Microsoft.VSTS.Scheduling.StoryPoints')) { $why.Add('not estimated') }
    if ($open -and $state -eq 'Active') {
        $idle = [int]((Get-Date) - [datetime](Get-AdoField $wi 'System.ChangedDate')).TotalDays
        if ($idle -ge $staleDays) { $why.Add("active, no update for $idle days") }
    }
    if ($type -eq 'Task' -and $open -and $state -ne 'New' -and $null -eq (Get-AdoField $wi 'Microsoft.VSTS.Scheduling.RemainingWork')) { $why.Add('no remaining work set') }
    if ($why.Count) { $attention.Add("| #$($wi.id) | $type | $(ConvertTo-AdoMarkdownCell (Get-AdoField $wi 'System.Title') 70) | $($why -join '; ') |") }
}
Write-Output '## Needs attention'
Write-Output ''
if ($attention.Count) {
    Write-Output '| ID | Type | Title | Why |'
    Write-Output '|---|---|---|---|'
    $attention | ForEach-Object { Write-Output $_ }
}
else { Write-Output 'Nothing flagged.' }
Write-Output ''

# 7. Full list
Write-Output '## All items'
Write-Output ''
Write-Output '| ID | Type | Title | State | Assigned to | Pts | Remaining |'
Write-Output '|---|---|---|---|---|---|---|'
foreach ($wi in $items) {
    Write-Output ("| #{0} | {1} | {2} | {3} | {4} | {5} | {6} |" -f $wi.id, (Get-AdoField $wi 'System.WorkItemType'),
        (ConvertTo-AdoMarkdownCell (Get-AdoField $wi 'System.Title') 70), (Get-AdoField $wi 'System.State'),
        (Format-AdoIdentity (Get-AdoField $wi 'System.AssignedTo')), (Get-AdoField $wi 'Microsoft.VSTS.Scheduling.StoryPoints' ''),
        (Get-AdoField $wi 'Microsoft.VSTS.Scheduling.RemainingWork' ''))
}
