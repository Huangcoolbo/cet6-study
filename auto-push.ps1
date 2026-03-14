Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sourceRoot = 'D:\Bo'
$targetRoot = 'D:\Ying'

Set-Location $targetRoot

function Sync-Directory($source, $target) {
    New-Item -ItemType Directory -Force -Path $target | Out-Null
    & robocopy $source $target /E /XO /XN /XC /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
    $code = $LASTEXITCODE
    if ($code -ge 8) {
        throw "robocopy failed for $source -> $target with exit code $code"
    }
}

try {
    Sync-Directory "$sourceRoot\cet6-data" "$targetRoot\data"

    $planSource = Join-Path $sourceRoot 'study-plan-week1.md'
    $planTargetDir = Join-Path $targetRoot 'plans'
    $planTarget = Join-Path $planTargetDir 'study-plan-week1.md'
    if (Test-Path $planSource) {
        New-Item -ItemType Directory -Force -Path $planTargetDir | Out-Null
        Copy-Item -Path $planSource -Destination $planTarget -Force
    }

    $status = git status --porcelain
    if (-not $status) {
        Write-Output 'No changes to sync or commit.'
        exit 0
    }

    git add .
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    git commit -m "auto-sync from D:\Bo: $timestamp"
    git push origin main
    Write-Output 'Changes synced and pushed successfully.'
} catch {
    Write-Error $_
    exit 1
}
