using namespace Microsoft.Azure.Commands.Profile.Models.Core
using namespace Microsoft.Azure.Storage

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