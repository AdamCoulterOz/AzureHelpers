function Get-DBConn {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$hostname, 
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$username, 
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$password
    )
    $connArgs = Get-DBConnArgs -hostname $hostname -username $username -password $password
    $connected = Connect-DB -arguments $connArgs
    if($connected) {
        return $connArgs
    } else {
        throw "Database connection failed."
    }
}
