Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = 'D:\Ying'
$expectedTasks = @(
    @{
        Name = 'CET6StudyAutoPush'
        AllowedScripts = @('D:\Ying\sync-cet6-study.ps1', 'D:\Ying\auto-push.ps1')
        PreferredScript = 'D:\Ying\sync-cet6-study.ps1'
        Note = 'Primary scheduled sync entrypoint. sync-cet6-study.ps1 is preferred; auto-push.ps1 is tolerated only as a compatibility fallback.'
    },
    @{
        Name = 'CET6StudyResumeCatchup'
        AllowedScripts = @('D:\Ying\resume-catchup.ps1')
        PreferredScript = 'D:\Ying\resume-catchup.ps1'
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

        $matchedScript = $null
        foreach ($allowedScript in $task.AllowedScripts) {
            $escapedScript = [regex]::Escape(('"' + $allowedScript + '"'))
            if ($execInfo.Arguments -match $escapedScript) {
                $matchedScript = $allowedScript
                break
            }
        }

        $status = if (-not $matchedScript) {
            'MISMATCH'
        } elseif ($matchedScript -eq $task.PreferredScript) {
            'OK'
        } else {
            'FALLBACK'
        }

        [pscustomobject]@{
            TaskName = $task.Name
            Status = $status
            Command = $execInfo.Command
            Arguments = $execInfo.Arguments
            PreferredScript = $task.PreferredScript
            AllowedScripts = ($task.AllowedScripts -join '; ')
            Note = $task.Note
        }
    } catch {
        [pscustomobject]@{
            TaskName = $task.Name
            Status = 'ERROR'
            Command = ''
            Arguments = ''
            PreferredScript = $task.PreferredScript
            AllowedScripts = ($task.AllowedScripts -join '; ')
            Note = $_.Exception.Message
        }
    }
}

$results | Format-Table -AutoSize

if ($results.Status -contains 'ERROR' -or $results.Status -contains 'MISMATCH') {
    exit 1
}

if ($results.Status -contains 'FALLBACK') {
    Write-Warning 'At least one task still points at a compatibility fallback instead of the preferred primary entrypoint.'
}

exit 0
