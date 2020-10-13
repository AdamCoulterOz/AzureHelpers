
function Get-DBConnArgs {
    [OutputType([string[]])]
    param (
        [string]$username,
        [string]$hostname,
        [string]$password
    )
    $arguments = @(
        "--enable-cleartext-plugin",
        "--user=$username@$hostname",
        "--password=$password",
        "--host=$hostname"
    )
    return $arguments
}

function Connect-DB {
    [OutputType([bool])]
    param ([string[]]$arguments)
    $success = $Null

    try {
        $nl = [Environment]::NewLine
        Write-Output "show databases; $nl exit $nl" | Invoke-Process -Command 'mysql' -Arguments $arguments
        $success = $true
    }
    catch {
        Write-Error "Failed to connect to database. $_"
        $success = $false
    }
    if ($Null -eq $success) {
        Throw "Connection null, not handled correctly."
    }
    Write-Information "Database connection success."
    return $success
}