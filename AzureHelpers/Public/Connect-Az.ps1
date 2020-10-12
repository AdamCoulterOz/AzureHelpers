function Connect-Az {
    [OutputType([String])]
    param (
        [ValidateSet('UserInteractive','ClientSecret','ClientCert','SystemAssigned','UserAssigned')]
        [string]$AuthMethod
    )
    $ErrorActionPreference = 'Stop'

    $env:AccessAuthMethod = $AuthMethod
    switch ([string]$AuthMethod) {
        'UserInteractive' { AzureLoginUser }
        'ClientSecret' { AzureLoginServicePrincipal }
        'ClientCert' { AzureLoginServicePrincipal -Certificate }
        'SystemAssigned' { AzureLoginManaged }
        'UserAssigned' { AzureLoginManaged -UserAssigned }
    }
}