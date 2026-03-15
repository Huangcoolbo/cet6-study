param(
    [int]$Count = 30,
    [string]$RevisionRange,
    [switch]$FailuresOnly,
    [switch]$SummaryOnly,
    [switch]$Compact,
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

    if ($category -match '^commit title should use ''<type>') {
        return "commit title should use '<type>: <specific summary>' with one of: docs, sync, data, plan, fix, chore, review."
    }

    if ($category -match '^commit title should not include timestamps or date-time strings') {
        return 'commit title should not include timestamps or date-time strings'
    }

    if ($category -match '^commit title summary still starts with a vague word') {
        return 'commit title summary still starts with a vague word'
    }

    $category = $category -replace " Got: '.+" , ''
    $category = $category -replace ": '.+" , ''
    return $category.Trim()
}

function Test-IsKnownLegacyReason {
    param(
        [string]$Reason
    )

    $legacyPatternReasons = @(
        'commit title should not include timestamps or date-time strings',
        "commit title should use '<type>: <specific summary>' with one of: docs, sync, data, plan, fix, chore, review.",
        'commit title summary still starts with a vague word'
    )

    return $legacyPatternReasons -contains $Reason
}

function Get-SuggestedAction {
    param(
        [object]$Summary,
        [object[]]$FailureSummary
    )

    if ($Summary.FailCount -eq 0) {
        return 'No follow-up needed; current audit slice is clean.'
    }

    if ($Summary.UnknownFailureCount -eq 0) {
        return 'Failures match the currently known legacy-bad-title buckets; review the sample titles to confirm no new false positives appeared.'
    }

    return 'Failures include reasons outside the usual legacy buckets; inspect the samples and validator rules before treating this as expected.'
}

function Get-AuditScope {
    param(
        [int]$Count,
        [string]$RevisionRange
    )

    if ($RevisionRange) {
        return [pscustomobject]@{
            Mode        = 'revision-range'
            Label       = "revision range $RevisionRange"
            RevisionRange = $RevisionRange
            CountLabel  = ''
        }
    }

    $countLabel = if ($Count -eq 1) { 'latest 1 commit' } else { "latest $Count commits" }
    return [pscustomobject]@{
        Mode          = 'count'
        Label         = $countLabel
        RevisionRange = ''
        CountLabel    = $countLabel
    }
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
            $samples = @(
                $_.Group |
                    Select-Object -First 3 |
                    ForEach-Object {
                        [pscustomobject]@{
                            Sha   = $_.Sha
                            Title = $_.Title
                        }
                    }
            )

            [pscustomobject]@{
                Reason         = $_.Name
                Count          = $_.Count
                IsKnownLegacy  = Test-IsKnownLegacyReason -Reason $_.Name
                Samples        = $samples
            }
        }
)

$knownLegacyFailureCount = @($failureSummary | Where-Object IsKnownLegacy | ForEach-Object Count | Measure-Object -Sum).Sum
if ($null -eq $knownLegacyFailureCount) {
    $knownLegacyFailureCount = 0
}

$unknownFailureCount = $failures.Count - $knownLegacyFailureCount
if ($unknownFailureCount -lt 0) {
    $unknownFailureCount = 0
}

$auditScope = Get-AuditScope -Count $Count -RevisionRange $RevisionRange

$summary = [pscustomobject]@{
    AuditedCount             = $results.Count
    PassCount                = $results.Count - $failures.Count
    FailCount                = $failures.Count
    KnownLegacyFailureCount  = $knownLegacyFailureCount
    UnknownFailureCount      = $unknownFailureCount
    LegacyOnlyFailures       = [bool]($failures.Count -gt 0 -and $unknownFailureCount -eq 0)
    FailuresOnly             = [bool]$FailuresOnly
    RevisionRange            = $auditScope.RevisionRange
    AuditMode                = $auditScope.Mode
    AuditScope               = $auditScope.Label
    RequestedCount           = if ($RevisionRange) { $null } else { $Count }
    Outcome                  = if ($failures.Count -eq 0) { 'clean' } elseif ($unknownFailureCount -eq 0) { 'legacy-only' } else { 'needs-review' }
}

$suggestedAction = Get-SuggestedAction -Summary $summary -FailureSummary $failureSummary

$payload = [pscustomobject]@{
    Summary         = $summary
    SuggestedAction = $suggestedAction
    FailureSummary  = $failureSummary
    Results         = @($displayResults)
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
    $lines.Add(('- Scope: `{0}`' -f $summary.AuditScope)) | Out-Null
    $lines.Add(('- Passed: {0}' -f $summary.PassCount)) | Out-Null
    $lines.Add(('- Failed: {0}' -f $summary.FailCount)) | Out-Null
    $lines.Add(('- Known legacy failures: {0}' -f $summary.KnownLegacyFailureCount)) | Out-Null
    $lines.Add(('- Unknown / investigate failures: {0}' -f $summary.UnknownFailureCount)) | Out-Null
    $lines.Add(('- Outcome: `{0}`' -f $summary.Outcome)) | Out-Null
    if ($summary.RevisionRange) {
        $lines.Add(('- Revision range: `{0}`' -f $summary.RevisionRange)) | Out-Null
    }
    elseif ($null -ne $summary.RequestedCount) {
        $lines.Add(('- Requested count: `{0}`' -f $summary.RequestedCount)) | Out-Null
    }
    if ($summary.FailuresOnly) {
        $lines.Add('- Output mode: failures only') | Out-Null
    }
    if ($Compact) {
        $lines.Add('- Output mode: compact summary') | Out-Null
    }
    $lines.Add(('- Suggested action: {0}' -f $suggestedAction)) | Out-Null

    if ($failureSummary.Count -gt 0) {
        $lines.Add('') | Out-Null
        $lines.Add('## Failure reason summary') | Out-Null
        $lines.Add('') | Out-Null
        foreach ($item in $failureSummary) {
            $bucketLabel = if ($item.IsKnownLegacy) { 'known-legacy' } else { 'investigate' }
            $lines.Add(('- {0} x {1} [{2}]' -f $item.Count, $item.Reason, $bucketLabel)) | Out-Null
            foreach ($sample in @($item.Samples)) {
                $sampleShortSha = if ($sample.Sha.Length -ge 7) { $sample.Sha.Substring(0, 7) } else { $sample.Sha }
                $lines.Add(('  - e.g. `{0}` {1}' -f $sampleShortSha, $sample.Title)) | Out-Null
            }
        }
    }
    else {
        $lines.Add('') | Out-Null
        $lines.Add('## Failure reason summary') | Out-Null
        $lines.Add('') | Out-Null
        $lines.Add('- No failing titles found in this audit slice.') | Out-Null
    }

    if (-not $Compact -and $displayResults.Count -gt 0) {
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

Write-Host ("Audited {0} commit title(s) from {1}: {2} pass, {3} fail. Outcome: {4}." -f $summary.AuditedCount, $summary.AuditScope, $summary.PassCount, $summary.FailCount, $summary.Outcome)
Write-Host ("Known legacy failures: {0}; unknown / investigate failures: {1}." -f $summary.KnownLegacyFailureCount, $summary.UnknownFailureCount)
Write-Host ("Suggested action: {0}" -f $suggestedAction)

if ($failureSummary.Count -gt 0) {
    Write-Host ''
    Write-Host 'Failure reason summary:' -ForegroundColor Yellow
    $failureSummary | ForEach-Object {
        Write-Host ("- {0} x {1}" -f $_.Count, $_.Reason) -ForegroundColor DarkYellow
        foreach ($sample in @($_.Samples)) {
            Write-Host ("  - e.g. {0} {1}" -f $sample.Sha.Substring(0, 7), $sample.Title) -ForegroundColor DarkYellow
        }
    }

    Write-Host ''
    Write-Host 'Use these grouped failures to decide whether the validator is catching real legacy problems or misclassifying acceptable titles.'
}
