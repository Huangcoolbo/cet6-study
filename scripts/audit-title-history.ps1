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

$repeatedTitles = @(
    $results |
        Group-Object Title |
        Where-Object Count -gt 1 |
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
                            Sha    = $_.Sha
                            Status = $_.Status
                        }
                    }
            )

            [pscustomobject]@{
                Title   = $_.Name
                Count   = $_.Count
                Samples = $samples
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

$topRepeatedTitle = if ($repeatedTitles.Count -gt 0) { $repeatedTitles[0] } else { $null }
[string[]]$topRepeatedTitleSampleStatuses = if ($null -ne $topRepeatedTitle) {
    @($topRepeatedTitle.Samples | ForEach-Object { $_.Status } | Select-Object -Unique)
}
else {
    @()
}
$topRepeatedTitleStatusMix = if (@($topRepeatedTitleSampleStatuses).Count -gt 0) {
    ($topRepeatedTitleSampleStatuses -join ',')
}
else {
    ''
}

$auditScope = Get-AuditScope -Count $Count -RevisionRange $RevisionRange

$newestEntry = if ($results.Count -gt 0) { $results[0] } else { $null }
$oldestEntry = if ($results.Count -gt 0) { $results[$results.Count - 1] } else { $null }

$summary = [pscustomobject]@{
    AuditedCount             = $results.Count
    PassCount                = $results.Count - $failures.Count
    FailCount                = $failures.Count
    FailureBucketCount       = $failureSummary.Count
    RepeatedTitleCount       = $repeatedTitles.Count
    TopRepeatedTitleCount    = if ($null -ne $topRepeatedTitle) { $topRepeatedTitle.Count } else { 0 }
    TopRepeatedTitle         = if ($null -ne $topRepeatedTitle) { $topRepeatedTitle.Title } else { '' }
    TopRepeatedTitleStatusMix = $topRepeatedTitleStatusMix
    KnownLegacyFailureCount  = $knownLegacyFailureCount
    UnknownFailureCount      = $unknownFailureCount
    LegacyOnlyFailures       = [bool]($failures.Count -gt 0 -and $unknownFailureCount -eq 0)
    HasFailures              = [bool]($failures.Count -gt 0)
    NeedsReview              = [bool]($failures.Count -gt 0 -and $unknownFailureCount -gt 0)
    FailuresOnly             = [bool]$FailuresOnly
    RevisionRange            = $auditScope.RevisionRange
    AuditMode                = $auditScope.Mode
    AuditScope               = $auditScope.Label
    RequestedCount           = if ($RevisionRange) { $null } else { $Count }
    NewestCommit             = if ($null -ne $newestEntry) { $newestEntry.Sha } else { '' }
    NewestTitle              = if ($null -ne $newestEntry) { $newestEntry.Title } else { '' }
    OldestCommit             = if ($null -ne $oldestEntry) { $oldestEntry.Sha } else { '' }
    OldestTitle              = if ($null -ne $oldestEntry) { $oldestEntry.Title } else { '' }
    Outcome                  = if ($failures.Count -eq 0) { 'clean' } elseif ($unknownFailureCount -eq 0) { 'legacy-only' } else { 'needs-review' }
}

$suggestedAction = Get-SuggestedAction -Summary $summary -FailureSummary $failureSummary

$payload = [pscustomobject]@{
    Summary         = $summary
    SuggestedAction = $suggestedAction
    FailureSummary  = $failureSummary
    RepeatedTitles  = $repeatedTitles
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
    $lines.Add(('- Failure buckets: {0}' -f $summary.FailureBucketCount)) | Out-Null
    $lines.Add(('- Repeated titles: {0}' -f $summary.RepeatedTitleCount)) | Out-Null
    if ($summary.TopRepeatedTitleCount -gt 0) {
        $lines.Add(('- Top repeated title: {0} x `{1}` [{2}]' -f $summary.TopRepeatedTitleCount, $summary.TopRepeatedTitle, $summary.TopRepeatedTitleStatusMix)) | Out-Null
    }
    $lines.Add(('- Outcome: `{0}`' -f $summary.Outcome)) | Out-Null
    $lines.Add(('- Needs review: `{0}`' -f $summary.NeedsReview.ToString().ToLowerInvariant())) | Out-Null
    if ($summary.RevisionRange) {
        $lines.Add(('- Revision range: `{0}`' -f $summary.RevisionRange)) | Out-Null
    }
    elseif ($null -ne $summary.RequestedCount) {
        $lines.Add(('- Requested count: `{0}`' -f $summary.RequestedCount)) | Out-Null
    }
    if ($summary.NewestCommit) {
        $newestShortSha = if ($summary.NewestCommit.Length -ge 7) { $summary.NewestCommit.Substring(0, 7) } else { $summary.NewestCommit }
        $lines.Add(('- Newest commit in scope: `{0}` {1}' -f $newestShortSha, $summary.NewestTitle)) | Out-Null
    }
    if ($summary.OldestCommit) {
        $oldestShortSha = if ($summary.OldestCommit.Length -ge 7) { $summary.OldestCommit.Substring(0, 7) } else { $summary.OldestCommit }
        $lines.Add(('- Oldest commit in scope: `{0}` {1}' -f $oldestShortSha, $summary.OldestTitle)) | Out-Null
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

    if ($repeatedTitles.Count -gt 0) {
        $lines.Add('') | Out-Null
        $lines.Add('## Repeated title summary') | Out-Null
        $lines.Add('') | Out-Null
        foreach ($item in $repeatedTitles) {
            $lines.Add(('- {0} x `{1}`' -f $item.Count, $item.Title)) | Out-Null
            foreach ($sample in @($item.Samples)) {
                $sampleShortSha = if ($sample.Sha.Length -ge 7) { $sample.Sha.Substring(0, 7) } else { $sample.Sha }
                $lines.Add(('  - e.g. `{0}` [{1}]' -f $sampleShortSha, $sample.Status)) | Out-Null
            }
        }
    }
    else {
        $lines.Add('') | Out-Null
        $lines.Add('## Repeated title summary') | Out-Null
        $lines.Add('') | Out-Null
        $lines.Add('- No repeated titles found in this audit slice.') | Out-Null
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
Write-Host ("Known legacy failures: {0}; unknown / investigate failures: {1}; failure buckets: {2}; repeated titles: {3}." -f $summary.KnownLegacyFailureCount, $summary.UnknownFailureCount, $summary.FailureBucketCount, $summary.RepeatedTitleCount)
if ($summary.TopRepeatedTitleCount -gt 0) {
    Write-Host ("Top repeated title: {0} x {1} [{2}]" -f $summary.TopRepeatedTitleCount, $summary.TopRepeatedTitle, $summary.TopRepeatedTitleStatusMix)
}
Write-Host ("Needs review: {0}." -f $summary.NeedsReview.ToString().ToLowerInvariant())
if ($summary.NewestCommit) {
    Write-Host ("Newest commit in scope: {0} {1}" -f $summary.NewestCommit.Substring(0, 7), $summary.NewestTitle)
}
if ($summary.OldestCommit) {
    Write-Host ("Oldest commit in scope: {0} {1}" -f $summary.OldestCommit.Substring(0, 7), $summary.OldestTitle)
}
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

if ($repeatedTitles.Count -gt 0) {
    Write-Host ''
    Write-Host 'Repeated title summary:' -ForegroundColor Yellow
    $repeatedTitles | ForEach-Object {
        Write-Host ("- {0} x {1}" -f $_.Count, $_.Title) -ForegroundColor DarkYellow
        foreach ($sample in @($_.Samples)) {
            Write-Host ("  - e.g. {0} [{1}]" -f $sample.Sha.Substring(0, 7), $sample.Status) -ForegroundColor DarkYellow
        }
    }

    Write-Host ''
    Write-Host 'Use repeated-title groups to judge whether the audit slice is technically clean but still too repetitive to be useful in history or workflow summaries.'
}
