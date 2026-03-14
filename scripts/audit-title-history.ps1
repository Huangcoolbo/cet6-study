param(
    [int]$Count = 30,
    [string]$RevisionRange,
    [switch]$FailuresOnly,
    [switch]$SummaryOnly,
    [switch]$AsJson,
    [switch]$AsMarkdown
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$validator = Join-Path $PSScriptRoot 'validate-title.ps1'

if (-not (Test-Path $validator)) {
    throw "Title validator not found: $validator"
}

function Get-ReasonCategory {
    param(
        [string]$Reason
    )

    if (-not $Reason) {
        return 'Unknown validation failure'
    }

    $category = $Reason.Trim()
    $category = $category -replace " Got: '.+" , ''
    $category = $category -replace ": '.+" , ''
    return $category.Trim()
}

Set-Location $repoRoot

$gitArgs = @('log', '--format=%H%x09%s')
if ($RevisionRange) {
    $gitArgs += $RevisionRange
}
else {
    $gitArgs += @('-n', $Count)
}

$entries = @(git @gitArgs)
if (-not $entries -or $entries.Count -eq 0) {
    Write-Host 'No commits found for the requested history slice.'
    exit 0
}

$results = [System.Collections.Generic.List[object]]::new()

foreach ($entry in $entries) {
    $parts = $entry -split "`t", 2
    if ($parts.Count -lt 2) {
        continue
    }

    $sha = $parts[0].Trim()
    $title = $parts[1].Trim()
    if (-not $title) {
        continue
    }

    $passed = $true
    $reason = ''

    try {
        & $validator -Kind commit -Title $title *> $null
    }
    catch {
        $passed = $false
        $reason = $_.Exception.Message.Trim()
    }

    $results.Add([pscustomobject]@{
        Sha            = $sha
        Status         = if ($passed) { 'PASS' } else { 'FAIL' }
        Title          = $title
        Reason         = $reason
        ReasonCategory = if ($passed) { '' } else { Get-ReasonCategory -Reason $reason }
    }) | Out-Null
}

$displayResults = if ($FailuresOnly) {
    @($results | Where-Object Status -eq 'FAIL')
}
else {
    $results
}

$failures = @($results | Where-Object Status -eq 'FAIL')
$failureSummary = @(
    $failures |
        Group-Object ReasonCategory |
        Sort-Object -Property @(
            @{ Expression = 'Count'; Descending = $true },
            @{ Expression = 'Name'; Descending = $false }
        ) |
        ForEach-Object {
            [pscustomobject]@{
                Reason = $_.Name
                Count  = $_.Count
            }
        }
)

$summary = [pscustomobject]@{
    AuditedCount  = $results.Count
    PassCount     = $results.Count - $failures.Count
    FailCount     = $failures.Count
    FailuresOnly  = [bool]$FailuresOnly
    RevisionRange = if ($RevisionRange) { $RevisionRange } else { '' }
}

$payload = [pscustomobject]@{
    Summary        = $summary
    FailureSummary = $failureSummary
    Results        = @($displayResults)
}

if ($AsJson) {
    $payload | ConvertTo-Json -Depth 6
    exit 0
}

if ($AsMarkdown) {
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('# Title Audit Summary') | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add(('- Audited: {0}' -f $summary.AuditedCount)) | Out-Null
    $lines.Add(('- Passed: {0}' -f $summary.PassCount)) | Out-Null
    $lines.Add(('- Failed: {0}' -f $summary.FailCount)) | Out-Null
    if ($summary.RevisionRange) {
        $lines.Add(('- Revision range: `{0}`' -f $summary.RevisionRange)) | Out-Null
    }
    if ($summary.FailuresOnly) {
        $lines.Add('- Output mode: failures only') | Out-Null
    }

    if ($failureSummary.Count -gt 0) {
        $lines.Add('') | Out-Null
        $lines.Add('## Failure reason summary') | Out-Null
        $lines.Add('') | Out-Null
        foreach ($item in $failureSummary) {
            $lines.Add(('- {0} × {1}' -f $item.Count, $item.Reason)) | Out-Null
        }
    }

    if ($displayResults.Count -gt 0) {
        $lines.Add('') | Out-Null
        $lines.Add('## Audited titles') | Out-Null
        $lines.Add('') | Out-Null
        foreach ($item in $displayResults) {
            $shortSha = if ($item.Sha.Length -ge 7) { $item.Sha.Substring(0, 7) } else { $item.Sha }
            if ($item.Status -eq 'PASS') {
                $lines.Add(('- PASS `{0}` {1}' -f $shortSha, $item.Title)) | Out-Null
            }
            else {
                $lines.Add(('- FAIL `{0}` {1}' -f $shortSha, $item.Title)) | Out-Null
                $lines.Add(('  - Reason: {0}' -f $item.Reason)) | Out-Null
            }
        }
    }

    $lines -join [Environment]::NewLine
    exit 0
}

if (-not $SummaryOnly) {
    $displayResults | ForEach-Object {
        if ($_.Status -eq 'PASS') {
            Write-Host ("[{0}] {1} {2}" -f $_.Status, $_.Sha.Substring(0, 7), $_.Title) -ForegroundColor Green
        }
        else {
            Write-Host ("[{0}] {1} {2}" -f $_.Status, $_.Sha.Substring(0, 7), $_.Title) -ForegroundColor Yellow
            Write-Host ("       -> {0}" -f $_.Reason) -ForegroundColor DarkYellow
        }
    }

    Write-Host ''
}

Write-Host ("Audited {0} commit title(s): {1} pass, {2} fail." -f $summary.AuditedCount, $summary.PassCount, $summary.FailCount)

if ($failureSummary.Count -gt 0) {
    Write-Host ''
    Write-Host 'Failure reason summary:' -ForegroundColor Yellow
    $failureSummary | ForEach-Object {
        Write-Host ("- {0} x {1}" -f $_.Count, $_.Reason) -ForegroundColor DarkYellow
    }

    Write-Host ''
    Write-Host 'Use these grouped failures to decide whether the validator is catching real legacy problems or misclassifying acceptable titles.'
}
