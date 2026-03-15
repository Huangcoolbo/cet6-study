param(
    [string[]]$Paths
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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

    $leafNames = @(Get-LeafList -Paths $ChangedPaths)
    if ($leafNames.Count -gt 0) {
        return ($leafNames -join ', ')
    }

    return 'tracked CET-6 repository files'
}

if ($null -eq $Paths -or $Paths.Count -eq 0) {
    $Paths = @(git diff --cached --name-only)
}

$changedPaths = @($Paths | Where-Object { $_ })
if (-not $changedPaths -or $changedPaths.Count -eq 0) {
    Write-Output 'chore: adjust tracked CET-6 repository files'
    exit 0
}

$dataPaths = @($changedPaths | Where-Object { $_ -like 'data/*' -or $_ -like 'data\*' })
$planPaths = @($changedPaths | Where-Object { $_ -like 'plans/*' -or $_ -like 'plans\*' })
$docPaths = @($changedPaths | Where-Object { $_ -match '(^|[\\/])(README\.md|WORKFLOW\.md|SYNC_POLICY\.md|PR_MERGE_POLICY\.md|CONTRIBUTING\.md|Todo\.md|COMMIT_MESSAGE_GUIDELINES\.md)$' -or $_ -like 'data/index/STATE_FILES.md' })
$scriptPaths = @($changedPaths | Where-Object { $_ -like '*.ps1' -or $_ -like '.github/*' -or $_ -like '.github\*' -or $_ -like 'scripts/*' -or $_ -like 'scripts\*' })

if ($dataPaths.Count -gt 0 -and $planPaths.Count -eq 0 -and $docPaths.Count -eq 0 -and $scriptPaths.Count -eq 0) {
    if ($dataPaths -contains 'data/index/dingtalk-state.json') {
        Write-Output 'data: refresh CET-6 study data and DingTalk reminder state'
        exit 0
    }

    if ($dataPaths.Count -le 3) {
        $leafNames = Get-LeafList -Paths $dataPaths
        Write-Output ('data: update CET-6 data files ' + ($leafNames -join ', '))
        exit 0
    }

    Write-Output 'data: update CET-6 study data'
    exit 0
}

if ($planPaths.Count -gt 0 -and $dataPaths.Count -eq 0 -and $docPaths.Count -eq 0 -and $scriptPaths.Count -eq 0) {
    if ($planPaths.Count -le 2) {
        $leafNames = Get-LeafList -Paths $planPaths
        Write-Output ('plan: refresh study plans ' + ($leafNames -join ', '))
        exit 0
    }

    Write-Output 'plan: refresh study plans'
    exit 0
}

if ($docPaths.Count -gt 0 -and $dataPaths.Count -eq 0 -and $planPaths.Count -eq 0 -and $scriptPaths.Count -eq 0) {
    if ($docPaths.Count -le 2) {
        $leafNames = Get-LeafList -Paths $docPaths
        Write-Output ('docs: clarify repository docs ' + ($leafNames -join ', '))
        exit 0
    }

    Write-Output 'docs: clarify CET-6 project documentation'
    exit 0
}

if ($scriptPaths.Count -gt 0 -and $dataPaths.Count -eq 0 -and $planPaths.Count -eq 0 -and $docPaths.Count -eq 0) {
    if ($scriptPaths.Count -le 2) {
        $leafNames = Get-LeafList -Paths $scriptPaths
        Write-Output ('fix: adjust repository automation ' + ($leafNames -join ', '))
        exit 0
    }

    Write-Output 'fix: adjust CET-6 repository automation'
    exit 0
}

if (($changedPaths -contains 'Todo.md') -and ($changedPaths -contains 'WORKFLOW.md') -and ($changedPaths -contains 'data/index/dingtalk-state.json') -and $planPaths.Count -eq 0 -and $scriptPaths.Count -eq 0) {
    Write-Output 'review: track DingTalk state follow-up and workflow notes'
    exit 0
}

if (($changedPaths -contains 'Todo.md') -and ($changedPaths -contains 'WORKFLOW.md') -and ($changedPaths -contains 'data/index/dingtalk-state.json') -and $scriptPaths.Count -gt 0 -and $planPaths.Count -eq 0) {
    Write-Output 'fix: refine DingTalk state workflow automation and follow-up tracking'
    exit 0
}

if ($dataPaths.Count -gt 0 -and $docPaths.Count -gt 0 -and $scriptPaths.Count -gt 0 -and $planPaths.Count -eq 0) {
    $indexDataPaths = @($dataPaths | Where-Object { $_ -like 'data/index/*' -or $_ -like 'data\index\*' })
    $dingtalkStateTouched = $dataPaths -contains 'data/index/dingtalk-state.json'

    if ($dingtalkStateTouched -and $indexDataPaths.Count -eq $dataPaths.Count) {
        Write-Output 'fix: refine DingTalk state workflow automation and docs'
        exit 0
    }

    if ($indexDataPaths.Count -eq $dataPaths.Count) {
        Write-Output 'fix: refine index data workflow automation and docs'
        exit 0
    }
}

if ($dataPaths.Count -gt 0 -and $scriptPaths.Count -gt 0 -and $planPaths.Count -eq 0 -and $docPaths.Count -eq 0) {
    $dataLeafNames = Get-LeafList -Paths $dataPaths -Limit 2
    if ($dataLeafNames.Count -gt 0) {
        Write-Output ('sync: refresh CET-6 data and automation for ' + ($dataLeafNames -join ', '))
        exit 0
    }

    Write-Output 'sync: refresh CET-6 data and automation'
    exit 0
}

if ($dataPaths.Count -gt 0 -and $docPaths.Count -gt 0 -and $planPaths.Count -eq 0 -and $scriptPaths.Count -eq 0) {
    $indexDataPaths = @($dataPaths | Where-Object { $_ -like 'data/index/*' -or $_ -like 'data\index\*' })
    $dingtalkStateTouched = $dataPaths -contains 'data/index/dingtalk-state.json'

    if ($dingtalkStateTouched -and $docPaths.Count -le 3 -and $dataPaths.Count -le 2) {
        Write-Output 'data: refresh DingTalk reminder state and supporting docs'
        exit 0
    }

    if ($indexDataPaths.Count -eq $dataPaths.Count -and $docPaths.Count -le 3) {
        Write-Output 'docs: clarify index data guidance and shared state files'
        exit 0
    }

    Write-Output 'data: refresh CET-6 study data and related documentation'
    exit 0
}

if ($docPaths.Count -gt 0 -and $scriptPaths.Count -gt 0 -and $dataPaths.Count -eq 0 -and $planPaths.Count -eq 0) {
    if (($changedPaths -contains 'Todo.md') -and ($changedPaths -contains 'WORKFLOW.md')) {
        Write-Output 'fix: refine title audit workflow guidance and backlog tracking'
        exit 0
    }

    Write-Output 'fix: clarify automation guidance and repository checks'
    exit 0
}

if ($planPaths.Count -gt 0 -and $dataPaths.Count -gt 0 -and $docPaths.Count -eq 0 -and $scriptPaths.Count -eq 0) {
    Write-Output 'plan: refresh study plans and supporting CET-6 data'
    exit 0
}

$mixedAreaSummary = Get-MixedAreaSummary -ChangedPaths $changedPaths
Write-Output ('chore: adjust CET-6 repository areas ' + $mixedAreaSummary)
