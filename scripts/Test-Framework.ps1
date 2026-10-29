#Requires -Version 5.1
<#
.SYNOPSIS
  Validate the framework's Copilot customization files. Run before committing changes to agents, skills or instructions.
  Exit code 0 = no errors (warnings allowed), 1 = errors.

.EXAMPLE
  ./scripts/Test-Framework.ps1
.EXAMPLE
  ./scripts/Test-Framework.ps1 -Path C:\src\payroll-portal     # validate an installed copy
#>
[CmdletBinding()]
param([string]$Path = (Split-Path -Parent $PSScriptRoot))
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$github = Join-Path $Path '.github'

function Get-Frontmatter {
    param([string]$File)
    $text = Get-Content -LiteralPath $File -Raw -Encoding UTF8
    $m = [regex]::Match($text, '\A---\r?\n(.*?)\r?\n---\r?\n', 'Singleline')
    if (-not $m.Success) { return $null }
    $fields = @{}
    foreach ($line in ($m.Groups[1].Value -split '\r?\n')) {
        $kv = [regex]::Match($line, '^([A-Za-z][\w-]*):\s*(.*)$')
        if ($kv.Success) { $fields[$kv.Groups[1].Value] = $kv.Groups[2].Value.Trim().Trim('"', "'") }
    }
    return @{ Fields = $fields; Body = $text.Substring($m.Length) }
}

function Get-Rel([string]$p) { return $p.Substring($Path.Length).TrimStart('\', '/') }

# Skills
$skillRoot = Join-Path $github 'skills'
$skillNames = @()
if (Test-Path -LiteralPath $skillRoot) {
    foreach ($dir in Get-ChildItem -LiteralPath $skillRoot -Directory) {
        $file = Join-Path $dir.FullName 'SKILL.md'
        if (-not (Test-Path -LiteralPath $file)) { $errors.Add("$(Get-Rel $dir.FullName): missing SKILL.md"); continue }
        $fm = Get-Frontmatter $file
        if (-not $fm) { $errors.Add("$(Get-Rel $file): missing YAML frontmatter"); continue }
        $name = if ($fm.Fields.ContainsKey('name')) { $fm.Fields['name'] } else { '' }
        $desc = if ($fm.Fields.ContainsKey('description')) { $fm.Fields['description'] } else { '' }
        if ($name -ne $dir.Name) { $errors.Add("$(Get-Rel $file): name '$name' must equal folder name '$($dir.Name)'") }
        if ($name -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') { $errors.Add("$(Get-Rel $file): name must be lowercase letters, digits and hyphens") }
        if (-not $desc) { $errors.Add("$(Get-Rel $file): description is required") }
        elseif ($desc.Length -gt 1024) { $errors.Add("$(Get-Rel $file): description is $($desc.Length) chars (max 1024)") }
        elseif ($desc -notmatch '(?i)\buse\b') { $warnings.Add("$(Get-Rel $file): description should say when to use the skill ('Use when ...')") }
        $lines = ($fm.Body -split '\r?\n').Count
        if ($lines -gt 500) { $warnings.Add("$(Get-Rel $file): body is $lines lines; move detail into references/ (aim for < 500)") }
        foreach ($link in [regex]::Matches($fm.Body, '\]\((?!https?:|#)([^)]+)\)')) {
            $target = Join-Path $dir.FullName ($link.Groups[1].Value -split '#')[0]
            if (-not (Test-Path -LiteralPath $target)) { $errors.Add("$(Get-Rel $file): broken link $($link.Groups[1].Value)") }
        }
        $skillNames += $name
    }
}

# Agents
$agentRoot = Join-Path $github 'agents'
if (Test-Path -LiteralPath $agentRoot) {
    foreach ($file in Get-ChildItem -LiteralPath $agentRoot -Filter '*.agent.md') {
        $fm = Get-Frontmatter $file.FullName
        if (-not $fm) { $errors.Add("$(Get-Rel $file.FullName): missing YAML frontmatter"); continue }
        $expected = $file.Name -replace '\.agent\.md$', ''
        if (-not $fm.Fields.ContainsKey('description') -or -not $fm.Fields['description']) { $errors.Add("$(Get-Rel $file.FullName): description is required") }
        if ($fm.Fields.ContainsKey('name') -and $fm.Fields['name'] -ne $expected) { $warnings.Add("$(Get-Rel $file.FullName): name '$($fm.Fields['name'])' differs from file name '$expected'") }
        if (-not $fm.Fields.ContainsKey('tools')) { $warnings.Add("$(Get-Rel $file.FullName): no tools list; the agent gets every tool") }
        if ($fm.Fields.ContainsKey('handoffs')) { $warnings.Add("$(Get-Rel $file.FullName): handoffs only work in VS Code's Local harness") }
        $section = [regex]::Match($fm.Body, '(?ms)^##\s+Skills to use\s*$(.*?)(?=^##\s|\z)')
        if ($section.Success) {
            foreach ($ref in [regex]::Matches($section.Groups[1].Value, '`([a-z0-9]+(?:-[a-z0-9]+)+)`')) {
                $n = $ref.Groups[1].Value
                if ($skillNames -notcontains $n -and -not (Test-Path -LiteralPath (Join-Path $agentRoot "$n.agent.md"))) {
                    $warnings.Add("$(Get-Rel $file.FullName): mentions skill '$n' which doesn't exist")
                }
            }
        }
    }
}

# Instructions
$instRoot = Join-Path $github 'instructions'
if (Test-Path -LiteralPath $instRoot) {
    foreach ($file in Get-ChildItem -LiteralPath $instRoot -Filter '*.instructions.md' -Recurse) {
        $fm = Get-Frontmatter $file.FullName
        if (-not $fm -or -not $fm.Fields.ContainsKey('applyTo')) { $warnings.Add("$(Get-Rel $file.FullName): no applyTo; it will only load on demand") }
        elseif ($fm.Fields['applyTo'] -eq '**') { $warnings.Add("$(Get-Rel $file.FullName): applyTo '**' loads on every request; consider copilot-instructions.md instead") }
    }
}
$main = Join-Path $github 'copilot-instructions.md'
if (-not (Test-Path -LiteralPath $main)) { $errors.Add('.github/copilot-instructions.md is missing') }
else {
    $mainLines = (Get-Content -LiteralPath $main).Count
    if ($mainLines -gt 200) { $warnings.Add(".github/copilot-instructions.md is $mainLines lines; keep always-on instructions short") }
}

# Scripts: Windows PowerShell 5.1 reads BOM-less files as ANSI, so keep them ASCII
foreach ($ps in Get-ChildItem -LiteralPath $Path -Recurse -File -Force -Include *.ps1, *.psm1 | Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' }) {
    $bytes = [IO.File]::ReadAllBytes($ps.FullName)
    if ($bytes | Where-Object { $_ -gt 127 } | Select-Object -First 1) { $errors.Add("$(Get-Rel $ps.FullName): contains non-ASCII characters (breaks in Windows PowerShell 5.1)") }
    $tokens = $null; $parseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($ps.FullName, [ref]$tokens, [ref]$parseErrors) | Out-Null
    foreach ($e in @($parseErrors)) { if ($e) { $errors.Add("$(Get-Rel $ps.FullName):$($e.Extent.StartLineNumber): $($e.Message)") } }
}

# ADO config
$adoConfig = Join-Path $skillRoot 'ado-work-items/ado.config.json'
if (Test-Path -LiteralPath $adoConfig) {
    try { $cfg = Get-Content -LiteralPath $adoConfig -Raw -Encoding UTF8 | ConvertFrom-Json } catch { $errors.Add("ado.config.json is not valid JSON: $($_.Exception.Message)"); $cfg = $null }
    if ($cfg -and ([string]$cfg.collectionUrl -match '^<')) { $warnings.Add('ado.config.json still has placeholder values (fine in the template; fill in for real use)') }
}

# TEAM-CUSTOMIZE markers
$markers = @(Get-ChildItem -LiteralPath $Path -Recurse -File -Force -Include *.md, *.json, *.yml |
    Where-Object { $_.FullName -notmatch '[\\/](docs|\.git)[\\/]' -and $_.Name -ne 'CHANGELOG.md' } |
    Select-String -Pattern 'TEAM-CUSTOMIZE' -SimpleMatch)

# Report
Write-Output "Skills: $($skillNames.Count)  Agents: $(@(Get-ChildItem -LiteralPath $agentRoot -Filter '*.agent.md' -ErrorAction SilentlyContinue).Count)"
Write-Output "TEAM-CUSTOMIZE placeholders remaining: $($markers.Count) in $(@($markers | Select-Object -ExpandProperty Path -Unique).Count) file(s)"
foreach ($w in $warnings) { Write-Output "WARN  $w" }
foreach ($e in $errors) { Write-Output "ERROR $e" }
if ($errors.Count) { Write-Output "FAILED with $($errors.Count) error(s)."; exit 1 }
Write-Output 'OK'
exit 0
