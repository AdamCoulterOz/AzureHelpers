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

        $null = Get-Command -ErrorAction Stop -CommandType Application dotnet

        Push-Location (New-Item -ErrorAction Stop -Type Directory "$PSScriptRoot/$projectFolder")

        $null = dotnet new classlib
        $null = dotnet add package $packageName @('-v', $packageVersion)
        $null = dotnet publish -c Release
  
        Pop-Location

        Write-Verbose -vb "Loading main assembly: $assemblyPath"  
        Add-Type -ErrorAction Stop -Path $assemblyPath
    }
}