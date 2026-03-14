Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Set-Location 'D:\Ying'

try {
    $status = git status --porcelain
    if (-not $status) {
        Write-Output 'No changes to commit.'
        exit 0
    }

    git add .
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    git commit -m "auto-sync: $timestamp"
    git push origin main
    Write-Output 'Changes pushed successfully.'
} catch {
    Write-Error $_
    exit 1
}
