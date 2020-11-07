function Remove-Databases {
    param (
        [string] $Server,
        [string] $User,
        [string] $Prefix = ''
    )

    $token = Get-AzToken -Target 'MySQL'
    $arguments = @(
        "--enable-cleartext-plugin"
        "--user=$User@$Server",
        "--password=$token",
        "--host=$Server"
    )

    $nl = [Environment]::NewLine
    $arguments += "--skip-column-names"
    $databaseLines = $("show databases; $nl exit $nl" | Invoke-Process -Command 'mysql' -Arguments $arguments)
    $databases = $databaseLines.Trim().Split("$nl")

    $exclude = @("Database", "mysql", "information_schema", "performance_schema", "sys")
    $nl = [Environment]::NewLine
    $overallStartTime = Get-Date
    foreach ($database in $databases) {
        if (-not ($exclude.Contains($database))) {
            if ($database.StartsWith($Prefix)) {
                $startTime = Get-Date
                Write-Information "Dropping database $database ..."
                $cmdArgs = @()
                $cmdArgs += $arguments
                $cmdArgs += @('-e', "use $database; SET FOREIGN_KEY_CHECKS=0; drop database $database;")
                Invoke-Process -Command 'mysql' -Arguments $cmdArgs | Write-Information
                $endTime = Get-Date
                $timeTaken = New-TimeSpan –Start $startTime –End $endTime
                Write-Information "Dropped database $database in $($timeTaken.TotalSeconds) seconds."
            }
        }
    }
    $overallEndTime = Get-Date
    $timeTaken = New-TimeSpan –Start $overallStartTime –End $overallEndTime
    Write-Information "Dropped all databases in $($timeTaken.TotalSeconds) seconds."
}