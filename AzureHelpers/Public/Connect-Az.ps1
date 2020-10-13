function Connect-Az {
    [OutputType([String])]
    param (
        [ValidateSet('UserInteractive','ClientSecret','ClientCert','SystemAssigned','UserAssigned')]
        [string]$AuthMethod
    )

    $ErrorActionPreference = 'Stop'
    if([string]::IsNullOrEmpty($AuthMethod)) {
        if(![string]::IsNullOrEmpty($env:AzureAuthMethod))
        {
            $AuthMethod = $env:AzureAuthMethod
        }
        else {
            Write-Error "AuthMethod must be set either as an argument or an environment variable."
        }
    }

    $env:AccessAuthMethod = $AuthMethod
    switch ([string]$AuthMethod) {
        'UserInteractive' { AzureLoginUser }
        'ClientSecret' { AzureLoginServicePrincipal }
        'ClientCert' { AzureLoginServicePrincipal -Certificate }
        'SystemAssigned' { AzureLoginManaged }
        'UserAssigned' { AzureLoginManaged -UserAssigned }
    }
}