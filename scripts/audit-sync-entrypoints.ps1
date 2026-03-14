Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = 'D:\Ying'
$expectedTasks = @(
    @{
        Name = 'CET6StudyAutoPush'
        ExpectedScript = 'D:\Ying\auto-push.ps1'
        Note = 'Current scheduled sync wrapper. Wrapper should delegate to sync-cet6-study.ps1.'
    },
    @{
        Name = 'CET6StudyResumeCatchup'
        ExpectedScript = 'D:\Ying\resume-catchup.ps1'
        Note = 'Resume catch-up task. Script should call D:\Ying\sync-cet6-study.ps1 after wake.'
    }
)

function Get-TaskXml([string]$taskName) {
    $xmlText = & schtasks /Query /TN $taskName /XML 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $xmlText) {
        throw "Scheduled task not found or unreadable: $taskName"
    }

    return [xml]$xmlText
}

function Get-ExecArguments($taskXml) {
    $namespace = New-Object System.Xml.XmlNamespaceManager($taskXml.NameTable)
    $namespace.AddNamespace('t', 'http://schemas.microsoft.com/windows/2004/02/mit/task')

    $commandNode = $taskXml.SelectSingleNode('//t:Actions/t:Exec/t:Command', $namespace)
    $argumentsNode = $taskXml.SelectSingleNode('//t:Actions/t:Exec/t:Arguments', $namespace)

    [pscustomobject]@{
        Command = if ($commandNode) { $commandNode.InnerText } else { '' }
        Arguments = if ($argumentsNode) { $argumentsNode.InnerText } else { '' }
    }
}

$results = foreach ($task in $expectedTasks) {
    try {
        $taskXml = Get-TaskXml -taskName $task.Name
        $execInfo = Get-ExecArguments -taskXml $taskXml
        $escapedExpectedScript = [regex]::Escape(('"' + $task.ExpectedScript + '"'))
        $matchesExpected = $execInfo.Arguments -match $escapedExpectedScript

        [pscustomobject]@{
            TaskName = $task.Name
            Status = if ($matchesExpected) { 'OK' } else { 'MISMATCH' }
            Command = $execInfo.Command
            Arguments = $execInfo.Arguments
            ExpectedScript = $task.ExpectedScript
            Note = $task.Note
        }
    } catch {
        [pscustomobject]@{
            TaskName = $task.Name
            Status = 'ERROR'
            Command = ''
            Arguments = ''
            ExpectedScript = $task.ExpectedScript
            Note = $_.Exception.Message
        }
    }
}

$results | Format-Table -AutoSize

if ($results.Status -contains 'ERROR' -or $results.Status -contains 'MISMATCH') {
    exit 1
}

exit 0
