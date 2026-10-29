#Requires -Version 5.1
<#
  Shared helpers for the ado-work-items skill.
  Works in Windows PowerShell 5.1 and PowerShell 7+.

  Guardrails enforced here (not just described in SKILL.md):
    - Only GET, POST and PATCH are possible. There is no DELETE code path.
    - Writes are limited to the work item types in "creatableTypes" and the fields in "writableFields".
    - States in "blockedStates" (e.g. Closed, Removed) can never be set by the skill.
    - Every applied write is appended to a local audit log.
    - Credentials: Windows integrated auth by default; PAT only from the ADO_PAT environment variable.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSVersion.Major -lt 6) {
    # Windows PowerShell 5.1 may default to TLS 1.0/1.1.
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    # Show non-ASCII text (names, dashes) correctly in Windows PowerShell output.
    try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch { }
}

$script:SkillRoot = Split-Path -Parent $PSScriptRoot
$script:Config = $null

function Get-AdoConfig {
    [CmdletBinding()]
    param()
    if ($script:Config) { return $script:Config }

    $path = if ($env:ADO_CONFIG) { $env:ADO_CONFIG } else { Join-Path $script:SkillRoot 'ado.config.json' }
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Azure DevOps skill config not found at '$path'. Fill in ado.config.json (see the Setup section of SKILL.md)."
    }
    $cfg = Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json

    $overrides = @{ collectionUrl = $env:ADO_COLLECTION_URL; project = $env:ADO_PROJECT; team = $env:ADO_TEAM }
    foreach ($key in $overrides.Keys) {
        if ($overrides[$key]) { $cfg | Add-Member -NotePropertyName $key -NotePropertyValue $overrides[$key] -Force }
    }

    foreach ($key in 'collectionUrl', 'project', 'apiVersion', 'auth') {
        $prop = $cfg.PSObject.Properties[$key]
        if (-not $prop -or [string]::IsNullOrWhiteSpace([string]$prop.Value) -or [string]$prop.Value -match '^<.*>$') {
            throw "ado.config.json: '$key' is not set. Replace the <placeholder> values (see the Setup section of SKILL.md)."
        }
    }
    $defaults = @{
        team = ''; aiTag = 'ai-assisted'; blockedTag = 'Blocked'; maxResults = 200; maxItemsPerWrite = 25
        creatableTypes = @(); writableFields = @(); blockedStates = @('Closed', 'Removed', 'Done')
    }
    foreach ($key in $defaults.Keys) {
        if (-not $cfg.PSObject.Properties[$key]) { $cfg | Add-Member -NotePropertyName $key -NotePropertyValue $defaults[$key] }
    }
    if ([string]$cfg.team -match '^<.*>$') { $cfg.team = '' }
    $cfg.collectionUrl = ([string]$cfg.collectionUrl).TrimEnd('/')
    $script:Config = $cfg
    return $cfg
}

function Invoke-AdoApi {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('GET', 'POST', 'PATCH')][string]$Method,
        [Parameter(Mandatory)][string]$Path,
        [hashtable]$Query,
        $Body,
        [string]$ContentType = 'application/json',
        [ValidateSet('Collection', 'Project', 'Team')][string]$Scope = 'Project'
    )
    $cfg = Get-AdoConfig
    $base = $cfg.collectionUrl
    if ($Scope -ne 'Collection') { $base = "$base/$([uri]::EscapeDataString($cfg.project))" }
    if ($Scope -eq 'Team') {
        if (-not $cfg.team) { throw "This request needs a team. Set 'team' in ado.config.json or the ADO_TEAM environment variable." }
        $base = "$base/$([uri]::EscapeDataString($cfg.team))"
    }

    $pairs = New-Object System.Collections.Generic.List[string]
    $hasVersion = $false
    if ($Query) {
        foreach ($key in $Query.Keys) {
            if ($key -eq 'api-version') { $hasVersion = $true }
            $pairs.Add("$key=$([uri]::EscapeDataString([string]$Query[$key]))")
        }
    }
    if (-not $hasVersion) { $pairs.Add("api-version=$($cfg.apiVersion)") }
    $uri = "$base/$($Path.TrimStart('/'))?$($pairs -join '&')"

    $params = @{ Method = $Method; Uri = $uri; ContentType = $ContentType; ErrorAction = 'Stop' }
    switch ($cfg.auth) {
        'windows' { $params.UseDefaultCredentials = $true }
        'pat' {
            if (-not $env:ADO_PAT) {
                throw "auth is 'pat' but the ADO_PAT environment variable is not set. Set it in your own terminal session; never paste a token into chat."
            }
            $token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($env:ADO_PAT)"))
            $params.Headers = @{ Authorization = "Basic $token" }
        }
        default { throw "ado.config.json: auth must be 'windows' or 'pat'." }
    }
    if ($null -ne $Body) {
        $json = if ($Body -is [string]) { $Body } else { ConvertTo-Json -InputObject $Body -Depth 20 -Compress }
        $params.Body = [Text.Encoding]::UTF8.GetBytes($json)
    }

    try {
        Invoke-RestMethod @params
    }
    catch {
        $detail = $_.Exception.Message
        if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
            $msg = $_.ErrorDetails.Message
            try { $parsed = $msg | ConvertFrom-Json; if ($parsed.PSObject.Properties['message']) { $msg = $parsed.message } } catch { }
            $detail = "$detail $msg"
        }
        if ($detail.Length -gt 600) { $detail = $detail.Substring(0, 600) + '...' }
        $hint = ''
        if ($detail -match '401|Unauthorized') { $hint = ' Check that you are signed in to Windows with an account that can open this project, or that ADO_PAT is valid.' }
        elseif ($detail -match '403|Forbidden') { $hint = ' Your account lacks permission for this action in Azure DevOps.' }
        elseif ($detail -match '(?i)VssVersionOutOfRange|api-version[^.]*(not supported|out of range|invalid)') { $hint = " Your server may not support api-version '$($cfg.apiVersion)'. Try a lower value in ado.config.json." }
        throw "Azure DevOps request failed: $Method $($uri -replace '\?.*$', '') -> $detail$hint"
    }
}

function Get-AdoField {
    param([Parameter(Mandatory)]$WorkItem, [Parameter(Mandatory)][string]$Name, $Default = $null)
    $prop = $WorkItem.fields.PSObject.Properties[$Name]
    if ($prop) { return $prop.Value }
    return $Default
}

function Format-AdoIdentity {
    param($Value)
    if ($null -eq $Value) { return '' }
    if ($Value -is [string]) { return ($Value -replace '\s*<[^>]+>$', '') }
    if ($Value.PSObject.Properties['displayName']) { return [string]$Value.displayName }
    return [string]$Value
}

function Get-AdoWorkItemUrl {
    param([Parameter(Mandatory)][int]$Id)
    $cfg = Get-AdoConfig
    return "$($cfg.collectionUrl)/$([uri]::EscapeDataString($cfg.project))/_workitems/edit/$Id"
}

function Get-AdoWorkItemsById {
    [CmdletBinding()]
    param([Parameter(Mandatory)][int[]]$Id, [switch]$WithRelations)
    $results = New-Object System.Collections.Generic.List[object]
    for ($i = 0; $i -lt $Id.Count; $i += 200) {
        $batch = $Id[$i..([Math]::Min($i + 199, $Id.Count - 1))]
        $query = @{ ids = ($batch -join ','); errorPolicy = 'omit' }
        if ($WithRelations) { $query['$expand'] = 'relations' }
        $resp = Invoke-AdoApi -Method GET -Path '_apis/wit/workitems' -Query $query -Scope Collection
        foreach ($wi in @($resp.value)) { if ($null -ne $wi) { $results.Add($wi) } }
    }
    return $results.ToArray()
}

function ConvertFrom-AdoHtml {
    param([string]$Html)
    if ([string]::IsNullOrWhiteSpace($Html)) { return '' }
    $t = $Html -replace "`r", ''
    $t = $t -replace '(?i)<br\s*/?>', "`n"
    $t = $t -replace '(?i)<li[^>]*>', "`n- "
    $t = $t -replace '(?i)</li>', ''
    $t = $t -replace '(?i)</(p|div|h[1-6]|tr|ul|ol|table)>', "`n"
    $t = $t -replace '(?i)<(b|strong)>', '**' -replace '(?i)</(b|strong)>', '**'
    $t = $t -replace '<[^>]+>', ''
    $t = [System.Net.WebUtility]::HtmlDecode($t)
    $t = $t -replace [char]0x00A0, ' '
    $t = $t -replace "[ \t]+`n", "`n"
    $t = $t -replace "`n{3,}", "`n`n"
    return $t.Trim()
}

function Format-AdoInline {
    param([string]$Text)
    $s = [System.Net.WebUtility]::HtmlEncode($Text)
    $s = [regex]::Replace($s, '\*\*(.+?)\*\*', '<b>$1</b>')
    $s = [regex]::Replace($s, '`([^`]+)`', '<code>$1</code>')
    return $s
}

function ConvertTo-AdoHtml {
    <# Minimal Markdown -> HTML for Azure DevOps rich-text fields: paragraphs, headings, bullet and numbered lists, bold, inline code. #>
    param([string]$Markdown)
    if ([string]::IsNullOrWhiteSpace($Markdown)) { return '' }
    $out = New-Object System.Text.StringBuilder
    $para = New-Object System.Collections.Generic.List[string]
    $list = ''
    foreach ($raw in (($Markdown -replace "`r", '') -split "`n")) {
        $line = $raw.TrimEnd()
        $bullet = [regex]::Match($line, '^\s*[-*]\s+(.*)$')
        $number = [regex]::Match($line, '^\s*\d+[.)]\s+(.*)$')
        $heading = [regex]::Match($line, '^\s*#{1,6}\s+(.*)$')
        $kind = if ($bullet.Success) { 'ul' } elseif ($number.Success) { 'ol' } else { '' }

        if ($kind -eq '' -or $kind -ne $list) {
            if ($list) { [void]$out.Append("</$list>"); $list = '' }
        }
        if ($kind -ne '' -or $heading.Success -or $line -eq '') {
            if ($para.Count -gt 0) { [void]$out.Append('<p>' + ($para -join '<br/>') + '</p>'); $para.Clear() }
        }

        if ($kind -ne '') {
            if (-not $list) { [void]$out.Append("<$kind>"); $list = $kind }
            $text = if ($kind -eq 'ul') { $bullet.Groups[1].Value } else { $number.Groups[1].Value }
            [void]$out.Append('<li>' + (Format-AdoInline $text) + '</li>')
        }
        elseif ($heading.Success) {
            [void]$out.Append('<p><b>' + (Format-AdoInline $heading.Groups[1].Value) + '</b></p>')
        }
        elseif ($line -ne '') {
            $para.Add((Format-AdoInline $line.Trim()))
        }
    }
    if ($list) { [void]$out.Append("</$list>") }
    if ($para.Count -gt 0) { [void]$out.Append('<p>' + ($para -join '<br/>') + '</p>') }
    return $out.ToString()
}

function ConvertTo-AdoTestStepsXml {
    <# Builds the Microsoft.VSTS.TCM.Steps XML from objects with .action and optional .expected #>
    param([Parameter(Mandatory)][object[]]$Steps)
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append("<steps id=`"0`" last=`"$($Steps.Count)`">")
    $n = 1
    foreach ($step in $Steps) {
        $action = [string]$step.action
        $expected = if ($step.PSObject.Properties['expected']) { [string]$step.expected } else { '' }
        if ([string]::IsNullOrWhiteSpace($action)) { throw "Test step $n has no action." }
        $type = if ([string]::IsNullOrWhiteSpace($expected)) { 'ActionStep' } else { 'ValidateStep' }
        $actionHtml = [System.Security.SecurityElement]::Escape('<DIV><P>' + (Format-AdoInline $action) + '</P></DIV>')
        $expectedHtml = if ($expected) { [System.Security.SecurityElement]::Escape('<DIV><P>' + (Format-AdoInline $expected) + '</P></DIV>') } else { '' }
        [void]$sb.Append("<step id=`"$n`" type=`"$type`"><parameterizedString isformatted=`"true`">$actionHtml</parameterizedString><parameterizedString isformatted=`"true`">$expectedHtml</parameterizedString><description/></step>")
        $n++
    }
    [void]$sb.Append('</steps>')
    return $sb.ToString()
}

function ConvertFrom-AdoTestStepsXml {
    param([string]$Xml)
    if ([string]::IsNullOrWhiteSpace($Xml)) { return @() }
    $doc = New-Object System.Xml.XmlDocument
    try { $doc.LoadXml($Xml) } catch { return @() }
    $rows = @()
    $n = 1
    foreach ($node in $doc.SelectNodes('//step|//compref')) {
        if ($node.Name -eq 'compref') { $rows += [pscustomobject]@{ Step = $n; Action = "(shared steps #$($node.GetAttribute('ref')))"; Expected = '' }; $n++; continue }
        $strings = $node.SelectNodes('parameterizedString')
        $action = if ($strings.Count -gt 0) { ConvertFrom-AdoHtml $strings[0].InnerText } else { '' }
        $expected = if ($strings.Count -gt 1) { ConvertFrom-AdoHtml $strings[1].InnerText } else { '' }
        $rows += [pscustomobject]@{ Step = $n; Action = $action; Expected = $expected }
        $n++
    }
    return $rows
}

function Assert-AdoCreatableType {
    param([Parameter(Mandatory)][string]$Type)
    $cfg = Get-AdoConfig
    if (@($cfg.creatableTypes) -notcontains $Type) {
        throw "Guardrail: the skill is not allowed to create '$Type' work items. Allowed: $(@($cfg.creatableTypes) -join ', '). Change creatableTypes in ado.config.json if your team agrees."
    }
}

function Assert-AdoWritableField {
    param([Parameter(Mandatory)][string]$Field)
    $cfg = Get-AdoConfig
    if (@($cfg.writableFields) -notcontains $Field) {
        throw "Guardrail: the skill is not allowed to write field '$Field'. Allowed fields are listed in writableFields in ado.config.json."
    }
}

function Assert-AdoStateAllowed {
    param([string]$State)
    if (-not $State) { return }
    $cfg = Get-AdoConfig
    if (@($cfg.blockedStates) -contains $State) {
        throw "Guardrail: moving a work item to '$State' is a human decision. Do it in Azure DevOps yourself."
    }
}

function Merge-AdoTags {
    param([string]$Existing, [string[]]$Add)
    $cfg = Get-AdoConfig
    $tags = New-Object System.Collections.Generic.List[string]
    $all = @()
    if ($Existing) { $all += ($Existing -split ';') }
    if ($Add) { $all += $Add }
    $all += $cfg.aiTag
    foreach ($tag in $all) {
        $clean = ([string]$tag).Trim()
        if ($clean -and -not ($tags | Where-Object { $_ -ieq $clean })) { $tags.Add($clean) }
    }
    return ($tags -join '; ')
}

function Write-AdoAudit {
    param([Parameter(Mandatory)][string]$Action, [Parameter(Mandatory)][string]$Detail)
    try {
        $dir = Join-Path $HOME '.copilot/logs'
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        $user = [Environment]::UserName
        $line = "{0}`t{1}`t{2}`t{3}" -f (Get-Date).ToString('o'), $user, $Action, $Detail
        Add-Content -LiteralPath (Join-Path $dir 'ado-skill-audit.log') -Value $line -Encoding UTF8
    }
    catch { Write-Warning "Could not write the audit log: $($_.Exception.Message)" }
}

function Write-AdoPreviewBanner {
    param([int]$Count, [string]$What)
    Write-Output ''
    Write-Output "PREVIEW ONLY - nothing was written to Azure DevOps."
    Write-Output "Would $What ($Count item(s)). Show this preview to the user. Re-run with -Apply only after the user explicitly approves."
    Write-Output ''
}

function ConvertTo-AdoMarkdownCell {
    param($Value, [int]$Max = 80)
    $s = ([string]$Value) -replace '\|', '\|' -replace "[`r`n]+", ' '
    if ($s.Length -gt $Max) { $s = $s.Substring(0, $Max - 3) + '...' }
    return $s
}

Export-ModuleMember -Function Get-AdoConfig, Invoke-AdoApi, Get-AdoField, Format-AdoIdentity, Get-AdoWorkItemUrl,
    Get-AdoWorkItemsById, ConvertFrom-AdoHtml, ConvertTo-AdoHtml, ConvertTo-AdoTestStepsXml, ConvertFrom-AdoTestStepsXml,
    Assert-AdoCreatableType, Assert-AdoWritableField, Assert-AdoStateAllowed, Merge-AdoTags, Write-AdoAudit,
    Write-AdoPreviewBanner, ConvertTo-AdoMarkdownCell
