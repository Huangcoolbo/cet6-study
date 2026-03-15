Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path $PSScriptRoot 'get-recommended-commit-title.ps1'

$cases = @(
    @{
        Paths = @('Todo.md', 'WORKFLOW.md', 'data/index/dingtalk-state.json')
        Expected = 'review: track DingTalk state follow-up and workflow notes'
    },
    @{
        Paths = @('Todo.md', 'WORKFLOW.md', 'dingtalk-state.json')
        Expected = 'review: track DingTalk state follow-up and workflow notes'
    },
    @{
        Paths = @('Todo.md', 'WORKFLOW.md', 'data/index/dingtalk-state.json', 'scripts/audit-title-history.ps1')
        Expected = 'review: refine DingTalk index follow-up guidance and title automation'
    },
    @{
        Paths = @('Todo.md', 'WORKFLOW.md', 'data/index/dingtalk-state.json', 'data/index/task-board.md', 'scripts/audit-title-history.ps1')
        Expected = 'review: refine DingTalk index follow-up guidance and title automation'
    },
    @{
        Paths = @('Todo.md', 'WORKFLOW.md', 'data/index/dingtalk-state.json', 'data/index/maintenance-log.md', 'data/input/translation-lines.tsv', 'data/input/writing-lines.tsv', 'scripts/get-recommended-commit-title.ps1', 'scripts/test-get-recommended-commit-title.ps1')
        Expected = 'review: refine DingTalk follow-up guidance title automation and training inputs'
    },
    @{
        Paths = @('.github/workflows/title-quality.yml', 'Todo.md', 'WORKFLOW.md')
        Expected = 'fix: refine title quality workflow guidance tests and backlog tracking'
    },
    @{
        Paths = @('.github/workflows/title-quality.yml', 'Todo.md', 'WORKFLOW.md', 'COMMIT_MESSAGE_GUIDELINES.md', 'scripts/get-recommended-commit-title.ps1', 'scripts/test-get-recommended-commit-title.ps1')
        Expected = 'fix: refine title quality workflow guidance tests and backlog tracking'
    },
    @{
        Paths = @('.github\workflows\title-quality.yml', 'Todo.md', 'WORKFLOW.md', 'COMMIT_MESSAGE_GUIDELINES.md', 'scripts\get-recommended-commit-title.ps1', 'scripts\test-get-recommended-commit-title.ps1')
        Expected = 'fix: refine title quality workflow guidance tests and backlog tracking'
    },
    @{
        Paths = @('title-quality.yml', 'Todo.md', 'WORKFLOW.md')
        Expected = 'fix: refine title quality workflow guidance tests and backlog tracking'
    },
    @{
        Paths = @('.github/workflows/title-quality.yml', 'Todo.md', 'WORKFLOW.md', 'data/index/maintenance-log.md', 'data/index/task-board.md', 'scripts/audit-title-history.ps1')
        Expected = 'fix: refine title quality workflow guidance tests and backlog tracking'
    },
    @{
        Paths = @('title-quality.yml', 'Todo.md', 'WORKFLOW.md', 'maintenance-log.md', 'task-board.md', 'audit-title-history.ps1')
        Expected = 'fix: refine title quality workflow guidance tests and backlog tracking'
    },
    @{
        Paths = @('.github/workflows/title-quality.yml', 'Todo.md', 'WORKFLOW.md', 'data/index/dingtalk-state.json', 'data/index/task-board.md', 'scripts/audit-title-history.ps1')
        Expected = 'fix: refine title quality workflow guidance tests and backlog tracking'
    },
    @{
        Paths = @('auto-push.ps1', 'resume-catchup.ps1', 'Todo.md', 'WORKFLOW.md')
        Expected = 'fix: refine sync entrypoint compatibility and workflow notes'
    },
    @{
        Paths = @('scripts\\auto-push.ps1', 'resume-catchup.ps1', 'Todo.md', 'WORKFLOW.md')
        Expected = 'fix: refine sync entrypoint compatibility and workflow notes'
    },
    @{
        Paths = @('data/index/dingtalk-state.json', 'WORKFLOW.md')
        Expected = 'data: refresh DingTalk reminder state and supporting docs'
    },
    @{
        Paths = @('data/index/STATE_FILES.md', 'WORKFLOW.md')
        Expected = 'docs: clarify index data guidance and shared state files'
    },
    @{
        Paths = @('Todo.md', 'data/index/dingtalk-state.json', 'maintenance-log.md')
        Expected = 'review: track DingTalk reminder follow-up and maintenance notes'
    },
    @{
        Paths = @('Todo.md', 'dingtalk-state.json', 'maintenance-log.md')
        Expected = 'review: track DingTalk reminder follow-up and maintenance notes'
    },
    @{
        Paths = @('Todo.md', 'WORKFLOW.md', 'data/index/dingtalk-state.json', 'data/index/maintenance-log.md', 'data/index/task-board.md', 'scripts/get-recommended-commit-title.ps1', 'scripts/test-get-recommended-commit-title.ps1')
        Expected = 'review: refine DingTalk index follow-up guidance and title automation'
    },
    @{
        Paths = @('.gitignore', 'Todo.md', 'WORKFLOW.md')
        Expected = 'chore: refine local audit artifact ignore rules and workflow notes'
    },
    @{
        Paths = @('repo/.gitignore', 'Todo.md', 'WORKFLOW.md')
        Expected = 'chore: refine local audit artifact ignore rules and workflow notes'
    },
    @{
        Paths = @('data/index/dingtalk-state.json', 'data/index/discord-study-flow.md', 'scripts/audit-title-history.ps1')
        Expected = 'review: refine DingTalk index tracking and title audit automation'
    },
    @{
        Paths = @('data/index/dingtalk-state.json', 'data/index/listening-verification-queue.md', 'data/index/maintenance-log.md', 'data/index/task-board.md', 'scripts/audit-title-history.ps1')
        Expected = 'review: refine DingTalk index tracking and title audit automation'
    }
)

$failures = [System.Collections.Generic.List[string]]::new()

foreach ($case in $cases) {
    $actual = (& $scriptPath -Paths $case.Paths).Trim()
    if ($actual -ne $case.Expected) {
        $failures.Add(("Expected '{0}' but got '{1}' for [{2}]" -f $case.Expected, $actual, ($case.Paths -join ', '))) | Out-Null
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "Recommended commit title samples passed ($($cases.Count) cases)."
