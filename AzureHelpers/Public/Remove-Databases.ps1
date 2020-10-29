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

    $commands = ""
    $exclude = @("Database", "mysql", "information_schema", "performance_schema", "sys")
    $nl = [Environment]::NewLine
    foreach ($database in $databases) {
        if (-not ($exclude.Contains($database))) {
            if ($database.StartsWith($Prefix)) {
                $startTime = Get-Date
                Write-Information "Dropping database $database ..."
                $commands += "use $database; $nl `
                        SET FOREIGN_KEY_CHECKS=0; $nl `
                        drop database $database; $nl exit $nl"
                Invoke-Process -Command 'mysql' -Arguments $arguments
                $endTime = Get-Date
                $timeTaken = New-TimeSpan –Start $startTime –End $endTime
                Write-Information "Dropped database $database in $($timeTaken.TotalSeconds) seconds."
            }
        }
    }
}