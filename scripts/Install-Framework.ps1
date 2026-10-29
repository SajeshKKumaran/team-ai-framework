#Requires -Version 5.1
<#
.SYNOPSIS
  Install the framework's Copilot customizations into a product repository, or into your user profile for the Copilot CLI.

.DESCRIPTION
  -TargetRepo <path>  Copies .github/copilot-instructions.md, .github/instructions, .github/agents and .github/skills
                      into the repository and adds .ai/drafts/ to its .gitignore.
                      An existing file is never overwritten unless -Force is given; instead the framework version is
                      written next to it as <name>.framework<ext> for you to merge.
  -User               Copies agents to ~/.copilot/agents and skills to ~/.copilot/skills (Copilot CLI, all folders).
                      Note: a user-level agent overrides a repository agent with the same name.

.EXAMPLE
  ./scripts/Install-Framework.ps1 -TargetRepo C:\src\payroll-portal
.EXAMPLE
  ./scripts/Install-Framework.ps1 -TargetRepo C:\src\payroll-portal -WhatIf
.EXAMPLE
  ./scripts/Install-Framework.ps1 -User
#>
[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Repo')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Repo')][string]$TargetRepo,
    [Parameter(Mandatory, ParameterSetName = 'User')][switch]$User,
    [switch]$Force
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$frameworkRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $frameworkRoot '.github'
$version = (Get-Content -LiteralPath (Join-Path $frameworkRoot 'VERSION') -Raw).Trim()
$copied = 0; $sideBySide = 0; $skipped = 0

function Copy-FrameworkFile {
    param([string]$From, [string]$To)
    $dir = Split-Path -Parent $To
    if (-not (Test-Path -LiteralPath $dir)) {
        if ($PSCmdlet.ShouldProcess($dir, 'Create directory')) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    }
    if ((Test-Path -LiteralPath $To) -and -not $Force) {
        $same = (Get-FileHash -LiteralPath $From).Hash -eq (Get-FileHash -LiteralPath $To).Hash
        if ($same) { $script:skipped++; return }
        $ext = [IO.Path]::GetExtension($To)
        $alt = $To.Substring(0, $To.Length - $ext.Length) + '.framework' + $ext
        if ($To -like '*ado.config.json') {
            Write-Host "  keep   $To (your settings; compare with the framework copy if needed)"
            $script:skipped++
            return
        }
        if ($PSCmdlet.ShouldProcess($alt, 'Write framework version next to existing file')) {
            Copy-Item -LiteralPath $From -Destination $alt -Force
            Write-Host "  merge  $To  <- review differences in $(Split-Path -Leaf $alt)"
        }
        $script:sideBySide++
        return
    }
    if ($PSCmdlet.ShouldProcess($To, 'Copy')) { Copy-Item -LiteralPath $From -Destination $To -Force }
    $script:copied++
}

function Copy-Tree {
    param([string]$From, [string]$To)
    if (-not (Test-Path -LiteralPath $From)) { return }
    Get-ChildItem -LiteralPath $From -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring($From.Length).TrimStart('\', '/')
        Copy-FrameworkFile -From $_.FullName -To (Join-Path $To $relative)
    }
}

if ($PSCmdlet.ParameterSetName -eq 'Repo') {
    $repo = (Resolve-Path -LiteralPath $TargetRepo).Path
    if (-not (Test-Path -LiteralPath (Join-Path $repo '.git'))) { Write-Warning "$repo doesn't look like a git repository root (.git not found). Continuing anyway." }
    $target = Join-Path $repo '.github'
    Write-Host "Installing team AI framework v$version into $repo"

    Copy-FrameworkFile -From (Join-Path $source 'copilot-instructions.md') -To (Join-Path $target 'copilot-instructions.md')
    foreach ($folder in 'instructions', 'agents', 'skills') { Copy-Tree -From (Join-Path $source $folder) -To (Join-Path $target $folder) }

    $gitignore = Join-Path $repo '.gitignore'
    $hasEntry = (Test-Path -LiteralPath $gitignore) -and ((Get-Content -LiteralPath $gitignore) -contains '.ai/drafts/')
    if (-not $hasEntry -and $PSCmdlet.ShouldProcess($gitignore, 'Add .ai/drafts/')) {
        Add-Content -LiteralPath $gitignore -Value "`n# AI drafts (team AI framework)`n.ai/drafts/"
        Write-Host '  added  .ai/drafts/ to .gitignore'
    }

    $marker = Join-Path $target 'ai-framework-version.txt'
    if ($PSCmdlet.ShouldProcess($marker, 'Record framework version')) { Set-Content -LiteralPath $marker -Value $version }

    Write-Host ''
    Write-Host "Done: $copied copied, $sideBySide need merging, $skipped unchanged or kept."
    Write-Host 'Next:'
    Write-Host '  1. Search the repo for TEAM-CUSTOMIZE and fill in the placeholders.'
    Write-Host '  2. Fill in .github/skills/ado-work-items/ado.config.json.'
    Write-Host '  3. Merge any *.framework.* files, then delete them.'
    Write-Host '  4. Commit on a branch and open a PR so the team reviews the rules.'
}
else {
    $copilotHome = Join-Path $HOME '.copilot'
    Write-Host "Installing team AI framework v$version agents and skills into $copilotHome"
    Copy-Tree -From (Join-Path $source 'agents') -To (Join-Path $copilotHome 'agents')
    Copy-Tree -From (Join-Path $source 'skills') -To (Join-Path $copilotHome 'skills')
    Write-Host ''
    Write-Host "Done: $copied copied, $sideBySide need merging, $skipped unchanged or kept."
    Write-Host "Fill in $copilotHome\skills\ado-work-items\ado.config.json (or set ADO_CONFIG to point at a shared config)."
    Write-Warning 'User-level agents override repository agents with the same name. Remove personal copies if a product repo customizes an agent.'
}
