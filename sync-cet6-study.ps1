Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sourceRoot = 'D:\Bo'
$targetRoot = 'D:\Ying'
$repoRoot = $targetRoot

$syncPairs = @(
    @{ Source = (Join-Path $sourceRoot 'cet6-data'); Target = (Join-Path $targetRoot 'data') },
    @{ Source = (Join-Path $sourceRoot 'study-plan-week1.md'); Target = (Join-Path $targetRoot 'plans\study-plan-week1.md') }
)

function Invoke-RobocopySync {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Target
    )

    if (-not (Test-Path $Source)) {
        return
    }

    New-Item -ItemType Directory -Force -Path $Target | Out-Null
    & robocopy $Source $Target /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP /XD '.git' '.openclaw' 'memory' 'skills' 'tools' | Out-Null
    $code = $LASTEXITCODE
    if ($code -ge 8) {
        throw "robocopy failed for $Source -> $Target with exit code $code"
    }
}

function Copy-FileIfPresent {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Target
    )

    if (-not (Test-Path $Source)) {
        return
    }

    $parent = Split-Path -Parent $Target
    if ($parent) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    Copy-Item -Path $Source -Destination $Target -Force
}


try {
    Set-Location $repoRoot

    foreach ($pair in $syncPairs) {
        $source = $pair.Source
        $target = $pair.Target

        if (-not (Test-Path $source)) {
            continue
        }

        if ((Get-Item $source).PSIsContainer) {
            Invoke-RobocopySync -Source $source -Target $target
        } else {
            Copy-FileIfPresent -Source $source -Target $target
        }
    }

    $status = git status --porcelain --untracked-files=normal
    if (-not $status) {
        Write-Output 'No CET-6 sync changes to commit.'
        exit 0
    }

    git add data plans README.md .gitignore sync-cet6-study.ps1 SYNC_POLICY.md PR_MERGE_POLICY.md WORKFLOW.md CONTRIBUTING.md Todo.md .github scripts
    $postAddStatus = git status --porcelain --untracked-files=normal
    if (-not $postAddStatus) {
        Write-Output 'No tracked CET-6 changes after filtering.'
        exit 0
    }

    $commitMessage = & (Join-Path $repoRoot 'scripts\get-recommended-commit-title.ps1')
    & (Join-Path $repoRoot 'scripts\validate-title.ps1') -Kind commit -Title $commitMessage
    git commit -m $commitMessage
    git push origin main
    Write-Output ('CET-6 materials synced and pushed successfully with commit message: ' + $commitMessage)
} catch {
    Write-Error $_
    exit 1
}
