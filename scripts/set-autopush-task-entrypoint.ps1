Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$taskName = 'CET6StudyAutoPush'
$repoRoot = 'D:\Ying'
$targetScript = Join-Path $repoRoot 'sync-cet6-study.ps1'

if (-not (Test-Path $targetScript)) {
    throw "Target sync script not found: $targetScript"
}

$taskXmlText = & schtasks /Query /TN $taskName /XML 2>$null
if ($LASTEXITCODE -ne 0 -or -not $taskXmlText) {
    throw "Scheduled task not found or unreadable: $taskName"
}

$taskXml = [xml]$taskXmlText
$namespace = New-Object System.Xml.XmlNamespaceManager($taskXml.NameTable)
$namespace.AddNamespace('t', 'http://schemas.microsoft.com/windows/2004/02/mit/task')

$commandNode = $taskXml.SelectSingleNode('//t:Actions/t:Exec/t:Command', $namespace)
$argumentsNode = $taskXml.SelectSingleNode('//t:Actions/t:Exec/t:Arguments', $namespace)
$descriptionNode = $taskXml.SelectSingleNode('//t:RegistrationInfo/t:Description', $namespace)

if (-not $commandNode -or -not $argumentsNode) {
    throw 'Unable to locate Exec command or arguments in scheduled task XML.'
}

$commandNode.InnerText = 'powershell.exe'
$argumentsNode.InnerText = '-NoProfile -ExecutionPolicy Bypass -File "D:\Ying\sync-cet6-study.ps1"'

if ($descriptionNode) {
    $descriptionNode.InnerText = 'Runs the CET-6 primary sync script every 15 minutes and syncs from D:\Bo to D:\Ying before pushing to GitHub.'
}

$tempXml = Join-Path ([System.IO.Path]::GetTempPath()) 'CET6StudyAutoPush.updated.xml'
try {
    $taskXml.Save($tempXml)
    & schtasks /Create /TN $taskName /XML $tempXml /F | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to update scheduled task $taskName"
    }

    Write-Output "Updated $taskName to call $targetScript directly."
}
finally {
    if (Test-Path $tempXml) {
        Remove-Item $tempXml -Force
    }
}
