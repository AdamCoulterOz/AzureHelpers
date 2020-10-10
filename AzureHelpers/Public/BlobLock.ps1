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

function Get-Lock {
    [OutputType([AccessCondition])]
    param ([AzureStorageBlob] $Blob)
    Write-Information "Acquire Lock ..."
    [string] $leaseId = $Null
    try {
        $leaseId =  $blob.ICloudBlob.AcquireLease($Null,$Null)  
    }
    catch {
        Write-Information "Failed to acquire lock." 
        return $Null
    }
    Write-Information "Acquired lock." 
    [AccessCondition] $leaseCondition = [AccessCondition]::GenerateLeaseCondition($leaseId)
    return $leaseCondition
}

function Remove-Lock {
    [OutputType([Bool])]
    param ([AzureStorageBlob] $Blob, [AccessCondition] $Lock)
    Write-Information "Release Lock ..."
    
    try {
        $Blob.ICloudBlob.ReleaseLease($Lock,$Null,$Null) 
    }
    catch {
        Write-Information "Failed to release Lock." 
        return $false
    }
    Write-Information "Released Lock." 
    return $true
}

Export-ModuleMember -Function @('Get-Blob', 'Get-Lock', 'Remove-Lock')