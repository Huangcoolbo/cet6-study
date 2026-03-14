param(
    [int]$Count = 30,
    [string]$RevisionRange,
    [switch]$FailuresOnly,
    [switch]$SummaryOnly,
    [switch]$AsJson
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
    AuditedCount = $results.Count
    PassCount    = $results.Count - $failures.Count
    FailCount    = $failures.Count
    FailuresOnly = [bool]$FailuresOnly
    RevisionRange = if ($RevisionRange) { $RevisionRange } else { '' }
}

if ($AsJson) {
    [pscustomobject]@{
        Summary        = $summary
        FailureSummary = $failureSummary
        Results        = @($displayResults)
    } | ConvertTo-Json -Depth 6
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
