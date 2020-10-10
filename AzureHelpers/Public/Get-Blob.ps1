using namespace Microsoft.Azure.Commands.Profile.Models.Core
using namespace Microsoft.Azure.Storage

function Get-Blob {
    [OutputType([AzureStorageBlob])]
    param (
        [PSAzureContext] $AzContext,
        [String] $ResourceGroupName,
        [String] $StorageAccountName,
        [String] $ContainerName,
        [String] $BlobName
    )
    Set-AzContext -Context $AzContext
    Set-AzCurrentStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
    $blob = Get-AzStorageBlob -Container $ContainerName -Blob $BlobName
    if($Null -eq $blob) {
        Write-Error "Couldn't find blob."
    }
    return $blob
}