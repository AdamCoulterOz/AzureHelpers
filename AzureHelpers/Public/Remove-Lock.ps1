using namespace Microsoft.Azure.Commands.Profile.Models.Core
using namespace Microsoft.Azure.Storage

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