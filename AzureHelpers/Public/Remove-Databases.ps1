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
                $commands += "use $database; $nl `
                        SET FOREIGN_KEY_CHECKS=0; $nl `
                        drop database $database; $nl"
            }
        }
    }
    $commands += "exit $nl"

    $commands | Invoke-Process -Command 'mysql' -Arguments $arguments
}