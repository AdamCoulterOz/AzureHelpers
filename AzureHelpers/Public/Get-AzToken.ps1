function Get-AzToken {
    [OutputType([String])]
    param (
        [ValidateSet('Management', 'MySQL', 'Storage')]
        [string]$Target = 'Management',

        [ValidateSet('UserInteractive', 'ClientSecret', 'ClientCert', 'SystemAssigned', 'UserAssigned', 'AppServiceSystemAssigned', 'AppServiceUserAssigned')]
        [string]$AuthMethod
    )

    if([string]::IsNullOrEmpty($AuthMethod)) {
        if(![string]::IsNullOrEmpty($env:AzureAuthMethod))
        {
            $AuthMethod = $env:AzureAuthMethod
        }
        else {
            $ErrorActionPreference = 'Stop'
            Write-Error "AuthMethod must be set either as an argument or an environment variable."
        }
    }


    Write-Information "Get token for $Target ..."
    [String] $token = $Null
    switch ($Target) {
        'Management' { $token = Get-AccessToken -AuthMethod $AuthMethod -ResourceURI 'https://management.azure.com' }
        'MySQL'      { $token = Get-AccessToken -AuthMethod $AuthMethod -ResourceURI 'https://ossrdbms-aad.database.windows.net' }
        'Storage'    { $token = Get-AccessToken -AuthMethod $AuthMethod -ResourceURI 'https://storage.azure.com' }
        Default { throw "Invalid target: {$Target}." }
    }
    Write-Information "Got token for: $Target."
    return $token
}