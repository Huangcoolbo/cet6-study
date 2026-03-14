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

function Get-CommitMessage {
    $changedPaths = @(git diff --cached --name-only)
    if (-not $changedPaths -or $changedPaths.Count -eq 0) {
        return 'chore: update tracked CET-6 repository files'
    }

    $dataPaths = @($changedPaths | Where-Object { $_ -like 'data/*' -or $_ -like 'data\*' })
    $planPaths = @($changedPaths | Where-Object { $_ -like 'plans/*' -or $_ -like 'plans\*' })
    $docPaths = @($changedPaths | Where-Object { $_ -match '(^|[\\/])(README\.md|WORKFLOW\.md|SYNC_POLICY\.md|PR_MERGE_POLICY\.md|CONTRIBUTING\.md|Todo\.md|COMMIT_MESSAGE_GUIDELINES\.md)$' -or $_ -like 'data/index/STATE_FILES.md' })
    $scriptPaths = @($changedPaths | Where-Object { $_ -like '*.ps1' -or $_ -like '.github/*' -or $_ -like '.github\*' -or $_ -like 'scripts/*' -or $_ -like 'scripts\*' })

    if ($dataPaths.Count -gt 0 -and $planPaths.Count -eq 0 -and $docPaths.Count -eq 0 -and $scriptPaths.Count -eq 0) {
        if ($dataPaths -contains 'data/index/dingtalk-state.json') {
            return 'data: refresh CET-6 study data and DingTalk reminder state'
        }

        if ($dataPaths.Count -le 3) {
            $leafNames = @($dataPaths | ForEach-Object { Split-Path $_ -Leaf } | Select-Object -Unique)
            return 'data: update CET-6 data files ' + ($leafNames -join ', ')
        }

        return 'data: update CET-6 study data'
    }

    if ($planPaths.Count -gt 0 -and $dataPaths.Count -eq 0 -and $docPaths.Count -eq 0 -and $scriptPaths.Count -eq 0) {
        if ($planPaths.Count -le 2) {
            $leafNames = @($planPaths | ForEach-Object { Split-Path $_ -Leaf } | Select-Object -Unique)
            return 'plan: refresh study plans ' + ($leafNames -join ', ')
        }

        return 'plan: refresh study plans'
    }

    if ($docPaths.Count -gt 0 -and $dataPaths.Count -eq 0 -and $planPaths.Count -eq 0 -and $scriptPaths.Count -eq 0) {
        if ($docPaths.Count -le 2) {
            $leafNames = @($docPaths | ForEach-Object { Split-Path $_ -Leaf } | Select-Object -Unique)
            return 'docs: clarify repository docs ' + ($leafNames -join ', ')
        }

        return 'docs: clarify CET-6 project documentation'
    }

    if ($scriptPaths.Count -gt 0 -and $dataPaths.Count -eq 0 -and $planPaths.Count -eq 0 -and $docPaths.Count -eq 0) {
        if ($scriptPaths.Count -le 2) {
            $leafNames = @($scriptPaths | ForEach-Object { Split-Path $_ -Leaf } | Select-Object -Unique)
            return 'fix: adjust repository automation ' + ($leafNames -join ', ')
        }

        return 'fix: adjust CET-6 repository automation'
    }

    if ($dataPaths.Count -gt 0 -and $scriptPaths.Count -gt 0 -and $planPaths.Count -eq 0 -and $docPaths.Count -eq 0) {
        return 'sync: align CET-6 materials from D:\Bo'
    }

    if ($dataPaths.Count -gt 0 -and $docPaths.Count -gt 0 -and $planPaths.Count -eq 0 -and $scriptPaths.Count -eq 0) {
        return 'data: update CET-6 study data and related documentation'
    }

    if ($docPaths.Count -gt 0 -and $scriptPaths.Count -gt 0 -and $dataPaths.Count -eq 0 -and $planPaths.Count -eq 0) {
        return 'fix: clarify automation guidance and repository checks'
    }

    if ($planPaths.Count -gt 0 -and $dataPaths.Count -gt 0 -and $docPaths.Count -eq 0 -and $scriptPaths.Count -eq 0) {
        return 'plan: refresh study plans and supporting CET-6 data'
    }

    $leafNames = @($changedPaths | ForEach-Object { Split-Path $_ -Leaf } | Select-Object -Unique | Select-Object -First 3)
    return 'chore: update CET-6 repository files ' + ($leafNames -join ', ')
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

    $commitMessage = Get-CommitMessage
    git commit -m $commitMessage
    git push origin main
    Write-Output ('CET-6 materials synced and pushed successfully with commit message: ' + $commitMessage)
} catch {
    Write-Error $_
    exit 1
}
