using namespace Microsoft.Azure.Commands.Common.Authentication
using namespace System.Management.Automation

function Select-AzSub {
    if(![string]::IsNullOrEmpty($env:AzureSubscription))
    {
        Set-AzContext -SubscriptionId $env:AzureSubscription | Write-Information
    }
}

function CheckEnvVariables {
    param ([string[]]$variables)
    foreach ($envVar in $variables) {
        $envValue = [Environment]::GetEnvironmentVariable($envVar)
        if ([string]::IsNullOrEmpty($envValue)) {
            $authType = $env:AccessAuthMethod
            Write-Error "Environment variable '$envVar' must be set to use the '$authType' authentication type."
        }
    }
}

function AzureLoginUser {
    $ErrorActionPreference = 'Stop'

    CheckEnvVariables @('AzureTenantId')
    Connect-AzAccount -Tenant $env:AzureTenantId | Write-Information
    Select-AzSub | Write-Information
}

function AzureLoginServicePrincipal {
    param ([switch]$Certificate = $false)
    $ErrorActionPreference = 'Stop'

    CheckEnvVariables @('AzureClientId', 'AzureTenantId')
    $clientId = $env:AzureClientId
    $tenantId = $env:AzureTenantId

    if($Certificate -eq $true) {
        CheckEnvVariables @('AzureClientCertThumbprint')
        $thumb = $env:AzureClientCertThumbprint
        Connect-AzAccount -Tenant $tenantId -ServicePrincipal -ApplicationId $clientId -CertificateThumbprint $thumb | Write-Information
    } else {
        CheckEnvVariables @('AzureClientSecret')
        $clientSecret = $env:AzureClientSecret
        $password = ConvertTo-SecureString $clientSecret -AsPlainText -Force
        $credential = [PSCredential]::new($clientId, $password)
        Connect-AzAccount -Tenant $tenantId -ServicePrincipal -Credential $credential | Write-Information
    }
    Select-AzSub | Write-Information
}

function AzureLoginManaged {
    param ([switch]$UserAssigned = $false)
    $ErrorActionPreference = 'Stop'
    
    if ($UserAssigned -eq $true) {
        CheckEnvVariables @('AzureClientId')
        $clientId = $env:AzureClientId
        Connect-AzAccount -Identity -AccountId $clientId | Write-Information
    }
    else {
        Connect-AzAccount -Identity | Write-Information
    }
    Select-AzSub | Write-Information
}

function AccessTokenLocal {
    [OutputType([String])]
    param ([string]$resourceURI)
    $ErrorActionPreference = 'Stop'

    $context = Get-AzContext
    $azureSession = [AzureSession]::Instance.AuthenticationFactory.Authenticate( `
            $context.Account, $context.Environment, $context.Subscription.TenantId, $null, [ShowDialog]::Never, $null, $resourceURI)
    $accessToken = $azureSession.AccessToken
    return $accessToken
}

function AccessTokenAppService {
    [OutputType([String])]
    param ([string]$ResourceURI, [switch]$UserAssigned = $false)
    $ErrorActionPreference = 'Stop'

    CheckEnvVariables @('IDENTITY_ENDPOINT', 'IDENTITY_HEADER')

    $tokenAuthURI = $env:IDENTITY_ENDPOINT
    $idHeader = $env:IDENTITY_HEADER
    $clientId = ""

    if ($UserAssigned) {
        CheckEnvVariables @('AzureClientId')
        $clientId = $env:AzureClientId
    }

    $headers = @{
        "X-IDENTITY-HEADER" = $idHeader
    }
    $queryParameters = @{
        'resource'    = $ResourceURI
        'api-version' = '2019-08-01'
    }
    if (![String]::IsNullOrEmpty($ClientId)) {
        $queryParameters.Add('client_id', $env:AzureClientId)
    }
    $tokenResponse = Invoke-RestMethod -Headers $headers -Uri $tokenAuthURI -Body $queryParameters
    $accessToken = $tokenResponse.access_token
    return $accessToken
}

function Get-AccessToken {
    [OutputType([String])]
    param (
        [ValidateSet('UserInteractive','ClientSecret','ClientCert','SystemAssigned','UserAssigned','AppServiceSystemAssigned','AppServiceUserAssigned')]
        [string]$AuthMethod,
        [string]$ResourceURI
    )
    $ErrorActionPreference = 'Stop'

    $env:AccessAuthMethod = $AuthMethod
    switch ([string]$AuthMethod) {
        'UserInteractive' { AzureLoginUser; return AccessTokenLocal $ResourceURI }
        'ClientSecret' { AzureLoginServicePrincipal; return AccessTokenLocal $ResourceURI }
        'ClientCert' { AzureLoginServicePrincipal -Certificate; return AccessTokenLocal $ResourceURI }
        'SystemAssigned' { AzureLoginManaged; return AccessTokenLocal $ResourceURI }
        'UserAssigned' { AzureLoginManaged -UserAssigned; return AccessTokenLocal $ResourceURI}

        'AppServiceSystemAssigned' { return AccessTokenAppService $ResourceURI }
        'AppServiceUserAssigned' { return AccessTokenAppService $ResourceURI -UserAssigned }
    }
}

