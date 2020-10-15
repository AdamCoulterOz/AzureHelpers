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
    $ErrorActionPreference = 'Stop'
    $connArgs = Get-DBConnArgs -hostname $hostname -username $username -password $password
    Write-Warning "Connection Arguments: $connArgs"
    $connected = Connect-DB -arguments $connArgs
    if($connected -eq $true) {
        return $connArgs
    } else {
        throw "Database connection failed."
    }
}
