function Get-DBConn {
    [OutputType([string[]])] param(
        [string]$hostname, [string]$username, [string]$password
    )
    $connArgs = Get-DBConnArgs -hostname $hostname -username $username -password $password
    $connected = Connect-DB -arguments $connArgs
    if($connected) {
        return $connArgs
    } else {
        throw "Database connection failed."
    }
}
