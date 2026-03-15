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
    function Get-LeafList {
        param(
            [string[]]$Paths,
            [int]$Limit = 3
        )

        return @(
            $Paths |
                ForEach-Object { Split-Path $_ -Leaf } |
                Where-Object { $_ } |
                Select-Object -Unique |
                Select-Object -First $Limit
        )
    }

    function Get-MixedAreaSummary {
        param(
            [string[]]$ChangedPaths
        )

        $labels = [System.Collections.Generic.List[string]]::new()

        if (@($ChangedPaths | Where-Object { $_ -like 'data/index/*' -or $_ -like 'data\index\*' }).Count -gt 0) {
            $labels.Add('index data') | Out-Null
        }
        if (@($ChangedPaths | Where-Object { $_ -like 'data/input/*' -or $_ -like 'data\input\*' }).Count -gt 0) {
            $labels.Add('training inputs') | Out-Null
        }
        if (@($ChangedPaths | Where-Object { $_ -like 'data/transcripts/*' -or $_ -like 'data\transcripts\*' }).Count -gt 0) {
            $labels.Add('listening transcripts') | Out-Null
        }
        if (@($ChangedPaths | Where-Object { $_ -like 'data/writing/*' -or $_ -like 'data\writing\*' }).Count -gt 0) {
            $labels.Add('writing materials') | Out-Null
        }
        if (@($ChangedPaths | Where-Object { $_ -like 'data/translation/*' -or $_ -like 'data\translation\*' }).Count -gt 0) {
            $labels.Add('translation materials') | Out-Null
        }
        if (@($ChangedPaths | Where-Object { $_ -like 'plans/*' -or $_ -like 'plans\*' }).Count -gt 0) {
            $labels.Add('study plans') | Out-Null
        }
        if (@($ChangedPaths | Where-Object { $_ -match '(^|[\\/])(README\.md|WORKFLOW\.md|SYNC_POLICY\.md|PR_MERGE_POLICY\.md|CONTRIBUTING\.md|Todo\.md|COMMIT_MESSAGE_GUIDELINES\.md)$' -or $_ -like 'data/index/STATE_FILES.md' }).Count -gt 0) {
            $labels.Add('project docs') | Out-Null
        }
        if (@($ChangedPaths | Where-Object { $_ -like '*.ps1' -or $_ -like '.github/*' -or $_ -like '.github\*' -or $_ -like 'scripts/*' -or $_ -like 'scripts\*' }).Count -gt 0) {
            $labels.Add('automation') | Out-Null
        }

        $areaLabels = @($labels | Select-Object -Unique | Select-Object -First 3)
        if ($areaLabels.Count -gt 0) {
            return ($areaLabels -join ', ')
        }

        $leafNames = Get-LeafList -Paths $ChangedPaths
        if ($leafNames.Count -gt 0) {
            return ($leafNames -join ', ')
        }

        return 'tracked CET-6 repository files'
    }

    $changedPaths = @(git diff --cached --name-only)
    if (-not $changedPaths -or $changedPaths.Count -eq 0) {
        return 'chore: adjust tracked CET-6 repository files'
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
            $leafNames = Get-LeafList -Paths $dataPaths
            return 'data: update CET-6 data files ' + ($leafNames -join ', ')
        }

        return 'data: update CET-6 study data'
    }

    if ($planPaths.Count -gt 0 -and $dataPaths.Count -eq 0 -and $docPaths.Count -eq 0 -and $scriptPaths.Count -eq 0) {
        if ($planPaths.Count -le 2) {
            $leafNames = Get-LeafList -Paths $planPaths
            return 'plan: refresh study plans ' + ($leafNames -join ', ')
        }

        return 'plan: refresh study plans'
    }

    if ($docPaths.Count -gt 0 -and $dataPaths.Count -eq 0 -and $planPaths.Count -eq 0 -and $scriptPaths.Count -eq 0) {
        if ($docPaths.Count -le 2) {
            $leafNames = Get-LeafList -Paths $docPaths
            return 'docs: clarify repository docs ' + ($leafNames -join ', ')
        }

        return 'docs: clarify CET-6 project documentation'
    }

    if ($scriptPaths.Count -gt 0 -and $dataPaths.Count -eq 0 -and $planPaths.Count -eq 0 -and $docPaths.Count -eq 0) {
        if ($scriptPaths.Count -le 2) {
            $leafNames = Get-LeafList -Paths $scriptPaths
            return 'fix: adjust repository automation ' + ($leafNames -join ', ')
        }

        return 'fix: adjust CET-6 repository automation'
    }

    if ($dataPaths.Count -gt 0 -and $scriptPaths.Count -gt 0 -and $planPaths.Count -eq 0 -and $docPaths.Count -eq 0) {
        $dataLeafNames = Get-LeafList -Paths $dataPaths -Limit 2
        if ($dataLeafNames.Count -gt 0) {
            return 'sync: refresh CET-6 data and automation for ' + ($dataLeafNames -join ', ')
        }

        return 'sync: refresh CET-6 data and automation'
    }

    if ($dataPaths.Count -gt 0 -and $docPaths.Count -gt 0 -and $planPaths.Count -eq 0 -and $scriptPaths.Count -eq 0) {
        $indexDataPaths = @($dataPaths | Where-Object { $_ -like 'data/index/*' -or $_ -like 'data\index\*' })
        $dingtalkStateTouched = $dataPaths -contains 'data/index/dingtalk-state.json'

        if ($dingtalkStateTouched -and $docPaths.Count -le 3 -and $dataPaths.Count -le 2) {
            return 'data: refresh DingTalk reminder state and supporting docs'
        }

        if ($indexDataPaths.Count -eq $dataPaths.Count -and $docPaths.Count -le 3) {
            return 'docs: clarify index data guidance and shared state files'
        }

        return 'data: refresh CET-6 study data and related documentation'
    }

    if ($docPaths.Count -gt 0 -and $scriptPaths.Count -gt 0 -and $dataPaths.Count -eq 0 -and $planPaths.Count -eq 0) {
        return 'fix: clarify automation guidance and repository checks'
    }

    if ($planPaths.Count -gt 0 -and $dataPaths.Count -gt 0 -and $docPaths.Count -eq 0 -and $scriptPaths.Count -eq 0) {
        return 'plan: refresh study plans and supporting CET-6 data'
    }

    $mixedAreaSummary = Get-MixedAreaSummary -ChangedPaths $changedPaths
    return 'chore: adjust CET-6 repository areas ' + $mixedAreaSummary
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
    & (Join-Path $repoRoot 'scripts\validate-title.ps1') -Kind commit -Title $commitMessage
    git commit -m $commitMessage
    git push origin main
    Write-Output ('CET-6 materials synced and pushed successfully with commit message: ' + $commitMessage)
} catch {
    Write-Error $_
    exit 1
}
