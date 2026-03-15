Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path $PSScriptRoot 'validate-title.ps1'

$cases = @(
    # Expected good titles under the current policy.
    @{ Kind = 'commit'; Title = 'docs: add PR contribution rules for external accounts'; ShouldPass = $true },
    @{ Kind = 'commit'; Title = 'sync: align CET-6 materials from D:\Bo'; ShouldPass = $true },
    @{ Kind = 'commit'; Title = 'fix: skip missing source paths in sync-cet6-study.ps1'; ShouldPass = $true },
    @{ Kind = 'commit'; Title = 'chore: add regression coverage for title validator'; ShouldPass = $true },
    @{ Kind = 'pr'; Title = 'review: tighten title validation examples'; ShouldPass = $true },
    @{ Kind = 'pr'; Title = 'docs: clarify sync responsibilities in contribution guide'; ShouldPass = $true },
    @{ Kind = 'commit'; Title = 'data: refresh CET-6 study data and DingTalk reminder state'; ShouldPass = $true },
    @{ Kind = 'commit'; Title = 'data: refresh DingTalk reminder state and supporting docs'; ShouldPass = $true },
    @{ Kind = 'commit'; Title = 'docs: clarify index data guidance and shared state files'; ShouldPass = $true },
    @{ Kind = 'commit'; Title = 'fix: clarify automation guidance and repository checks'; ShouldPass = $true },
    @{ Kind = 'commit'; Title = 'chore: adjust CET-6 repository files Todo.md, WORKFLOW.md, dingtalk-state.json'; ShouldPass = $true },
    @{ Kind = 'commit'; Title = 'Merge branch ''master'' into main'; ShouldPass = $true },
    @{ Kind = 'commit'; Title = 'Merge pull request #12 from teammate/docs-title-fix'; ShouldPass = $true },
    @{ Kind = 'commit'; Title = 'Merge master into main'; ShouldPass = $true },
    @{ Kind = 'commit'; Title = 'Initial CET-6 study project sync'; ShouldPass = $true },
    @{ Kind = 'commit'; Title = 'Initial commit'; ShouldPass = $true },

    # Known bad / vague titles, including legacy subjects from the actual git history.
    @{ Kind = 'commit'; Title = 'update'; ShouldPass = $false },
    @{ Kind = 'commit'; Title = 'sync'; ShouldPass = $false },
    @{ Kind = 'commit'; Title = 'auto-sync from D:\Bo: 2026-03-14 17:27:02'; ShouldPass = $false },
    @{ Kind = 'commit'; Title = 'sync: CET-6 materials from D:\Bo (2026-03-14 17:35:00)'; ShouldPass = $false },
    @{ Kind = 'pr'; Title = 'docs: clarify sync policy on 2026-03-14'; ShouldPass = $false },
    @{ Kind = 'commit'; Title = 'Update auto-sync workflow from D:\Bo to D:\Ying'; ShouldPass = $false },
    @{ Kind = 'commit'; Title = 'Update auto-push script to target main'; ShouldPass = $false },
    @{ Kind = 'commit'; Title = 'update CET-6 study data and DingTalk reminder state; clarify project documentation; adjust repository automation'; ShouldPass = $false },
    @{ Kind = 'commit'; Title = 'chore: update CET-6 repository files Todo.md, WORKFLOW.md, dingtalk-state.json'; ShouldPass = $false },
    @{ Kind = 'commit'; Title = 'data: update CET-6 study data and DingTalk reminder state'; ShouldPass = $false },
    @{ Kind = 'commit'; Title = 'docs: update'; ShouldPass = $false },
    @{ Kind = 'commit'; Title = 'docs: README'; ShouldPass = $false },
    @{ Kind = 'commit'; Title = 'fix: typo'; ShouldPass = $false },
    @{ Kind = 'pr'; Title = 'review: typo'; ShouldPass = $false },
    @{ Kind = 'pr'; Title = 'chore: cleanup'; ShouldPass = $false }
)

$failures = [System.Collections.Generic.List[string]]::new()

foreach ($case in $cases) {
    try {
        & $scriptPath -Kind $case.Kind -Title $case.Title *> $null
        $passed = $true
    }
    catch {
        $passed = $false
    }

    if ($passed -ne $case.ShouldPass) {
        $expected = if ($case.ShouldPass) { 'pass' } else { 'fail' }
        $actual = if ($passed) { 'pass' } else { 'fail' }
        $failures.Add("Expected $expected but got $actual for [$($case.Kind)] '$($case.Title)'")
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "Title validation samples passed ($($cases.Count) cases)."
