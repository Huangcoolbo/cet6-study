param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('commit', 'pr')]
    [string]$Kind,

    [Parameter(Mandatory = $true)]
    [string]$Title
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$title = $Title.Trim()
if (-not $title) {
    throw "${Kind} title is empty."
}

$bannedExact = @(
    'update',
    'fix',
    'sync',
    'change files',
    'auto-sync',
    'misc cleanup',
    'daily update',
    'update files',
    'fix stuff',
    'misc',
    'cleanup'
)

$allowedTypes = @('docs', 'sync', 'data', 'plan', 'fix', 'chore', 'review')
$allowedTypePattern = ($allowedTypes -join '|')

$allowedSpecialTitles = @(
    '^Merge pull request #\d+ .+',
    '^Merge (remote-tracking )?branch .+',
    '^Merge branch .+',
    '^Merge .+ into .+',
    '^Initial commit$',
    '^Initial CET-6 study project sync$'
)

function Fail([string]$message) {
    Write-Error $message
    exit 1
}

if ($bannedExact -contains $title.ToLowerInvariant()) {
    Fail "$Kind title is too vague: '$title'. Use a specific subject that says what changed and where."
}

if ($allowedSpecialTitles | Where-Object { $title -match $_ }) {
    Write-Host "Validated $Kind title via allowed special-case pattern: $title"
    exit 0
}

if ($title.Length -lt 12) {
    Fail "$Kind title is too short: '$title'. Make it more specific."
}

if ($title -match '^[A-Z][a-z]+$') {
    Fail "$Kind title looks too generic: '$title'."
}

$hasAllowedPrefix = $title -match "^(?:$allowedTypePattern):\s+.+"
if (-not $hasAllowedPrefix) {
    Fail "$Kind title should use '<type>: <specific summary>' with one of: $($allowedTypes -join ', '). Got: '$title'"
}

$summary = ($title -replace "^(?:$allowedTypePattern):\s+", '').Trim()
if ($summary.Length -lt 8) {
    Fail "$Kind title summary is too short: '$title'"
}

if ($summary -notmatch '[A-Za-z0-9]' -or $summary -notmatch '\s') {
    Fail "$Kind title summary should include a clear object and action, not just a single token: '$title'"
}

if ($summary -match '^(update|fix|sync|cleanup|misc|changes?)(\s|$)') {
    Fail "$Kind title summary still starts with a vague word: '$title'"
}

if ($title -match '\b\d{4}-\d{2}-\d{2}(?:[ T]\d{2}:\d{2}(?::\d{2})?)?\b') {
    Fail "$Kind title should not include timestamps or date-time strings: '$title'"
}

Write-Host "Validated $Kind title: $title"
