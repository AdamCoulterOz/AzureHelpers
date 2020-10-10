using namespace System
using namespace System.IO
using namespace System.Collections.Generic
using namespace System.Diagnostics
using namespace System.Threading.Tasks

function Invoke-Process {
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Command,

        [Parameter(ValueFromRemainingArguments = $true)]
        [String[]] $Arguments,

        [Parameter(ValueFromPipeline)]
        [string]$Pipeline
    )

    $commandPath = ""
    $exists = Test-Path $Command
    if ($exists -eq $True) { 
        $commandPath = $Command
    }
    else { 
        try {
            $pathCommand = Get-Command $Command -ErrorAction Stop
            $commandPath = $pathCommand.Path
        }
        catch {
            Write-Error "Specified command '$Command' cannot be found as a program in PATH or filesystem."
        }
    }

    $InformationPreference = 'Continue'
    $output = ""
    [Process] $process = [Process]::new()
    $process.StartInfo.FileName = $commandPath
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.RedirectStandardError = $true
    $process.StartInfo.RedirectStandardInput = $true
    $Arguments.ForEach( { $process.StartInfo.ArgumentList.Add($_) })

    $ErrEvent = Register-ObjectEvent -Action {
        Write-Warning $EventArgs.Data
    } -InputObject $process -EventName ErrorDataReceived

    $process.Start() | Out-Null
    $process.BeginErrorReadLine() | Out-Null

    if(![String]::IsNullOrEmpty($Pipeline))
    {
        [Task] $writerTask = $process.StandardInput.WriteAsync($Pipeline)
    }

    # cant set ReadTimeout as it isnt supported on this Stream Type
    #$process.StandardOutput.BaseStream.ReadTimeout = 200
    while (!$process.StandardOutput.EndOfStream) {
        $outputLine = $process.StandardOutput.ReadLine()
        Write-Information $outputLine
        $output += $outputLine + [Environment]::NewLine
    }
    
    if(![String]::IsNullOrEmpty($Pipeline))
    {
        $writerTask.GetAwaiter().GetResult() | Out-Null
    }
        
    $process.WaitForExit() | Out-Null
    $exitCode = $process.ExitCode
    $process.Close() | Out-Null

    Unregister-Event -SourceIdentifier $ErrEvent.Name | Out-Null

    if ($exitCode -gt 0) {
        $errorMsg = "Process failed to complete successfully: $Command, with exit code: $exitCode."
        Write-Error $errorMsg
        throw $errorMsg
    }

    Write-Information "Completed $Command."
    return $output
}