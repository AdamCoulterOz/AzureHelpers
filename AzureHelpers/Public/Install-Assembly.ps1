function Install-Assembly {
    param ([string]$Name, [string]$Version)

    $packageName = $Name
    $packageVersion = $Version

    $assembly = "$packageName.dll"
    $projectFolder = "assemblies/$packageName.$packageVersion"
    $assemblyPath = "$PSScriptRoot/$projectFolder/bin/Release/*/publish/$assembly"
    $existingAssemblyPath = Convert-Path -ErrorAction Ignore $assemblyPath

    if ($existingAssemblyPath) {
        Write-Verbose -vb "Package '$packageName' already installed. Loading main assembly: $existingAssemblyPath"
        Add-Type -ErrorAction Stop -LiteralPath $existingAssemblyPath
    }
    else {

        Write-Verbose -vb "Installing package '$packageName'..."

        Get-Command -ErrorAction Stop -CommandType Application dotnet | Write-Information

        Push-Location (New-Item -ErrorAction Stop -Type Directory "$PSScriptRoot/$projectFolder")

        Invoke-Process -Command dotnet -Arguments @('new', 'classlib') | Write-Information
        Invoke-Process -Command dotnet -Arguments @('add', 'package','-v', $packageVersion) | Write-Information
        Invoke-Process -Command dotnet -Arguments @('publish', '-c','Release') | Write-Information
  
        Pop-Location

        Write-Verbose -vb "Loading main assembly: $assemblyPath"  
        Add-Type -ErrorAction Stop -Path $assemblyPath

        Write-Information "Adding Azure.Identity Type ..."
        $dlls = (Get-ChildItem -Path "$PSScriptRoot/$projectFolder/bin/Release/*/publish/" -Filter "*.dll").FullName
        foreach ($dll in $dlls)
        {
            Add-Type -Path $dll
        }
        #Add-Type -ErrorAction Stop -Path "$PSScriptRoot/Azure.Identity/Azure.Identity.dll" | Write-Information
        Write-Information "Added Azure.Identity Type."
    }
}