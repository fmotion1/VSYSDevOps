using namespace System.Management.Automation

class NodeVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-InstalledNodeVersionsCompleter
        return $v
    }
}
function Get-InstalledNodeVersionsWithNVM {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, HelpMessage="Display only versions")]
        [switch]
        $VersionOnly,

        [Parameter(Mandatory=$false, HelpMessage="Display only version and path")]
        [switch]
        $VersionAndPath,

        [Parameter(HelpMessage="Return only specific versions.")]
        [ValidateSet([NodeVersions])]
        [string[]]
        $FilterVersions,

        [ValidateSet("CURRENT", "OLD", "ALL", IgnoreCase=$true)]
        [string]$Branch = "ALL",

        [switch]$ShowBranch,
        [switch]$Table
    )

    # Ensure VersionOnly and VersionAndPath are not used together
    if ($VersionOnly -and $VersionAndPath) {
        throw "VersionOnly and VersionAndPath cannot be used together."
    }

    $NVMCmd = Get-Command nvm.exe
    $NVMRoot = (& $NVMCmd root)[1] -replace 'Current Root: '
    $NodeDirsFull = ((Get-ChildItem -Path $NVMRoot -Filter 'v*' -Directory).FullName).TrimStart('v')
    $NodeVersions = (& $NVMCmd list) | % { $_ -split '\r?\n'} | % { if(![String]::IsNullOrEmpty($_)){ $_ } }
    $NodeVersions = (($NodeVersions -replace '\* ', '') -replace '\(([\w\s\-]+)\)', '').Trim()

    # Function to convert output to the format required by Format-SpectreTable
    function ConvertTo-SpectreTableFormat {
        param ($Data)

        $tableData = @()
        foreach ($item in $Data) {
            foreach ($property in $item.PSObject.Properties) {
                $tableData += [PSCustomObject]@{
                    Name = $property.Name
                    Value = $property.Value
                }
            }
        }
        return $tableData
    }

    $directoryString = $NodeDirsFull
    $versionString = $NodeVersions

    # Split the strings into arrays
    $versions = $versionString -split "`n"
    $directories = $directoryString -split "`n"

    # Create a hashtable to associate versions with directories
    $versionDirectoryMap = @{}
    foreach ($dir in $directories) {
        if ($dir -match "v(\d+\.\d+\.\d+)$") {
            $versionDirectoryMap[$Matches[1]] = $dir
        }
    }

    # Filter the versions if FilterVersions is specified
    if ($FilterVersions) {
        $versions = $versions | Where-Object { $_ -in $FilterVersions }
    }

    # Process based on switch parameters
    if ($VersionOnly) {
        if ($ShowBranch) {
            $output = @()
            foreach ($version in $versions) {
                $branchValue = if ($version.StartsWith("0")) { "OLD" } else { "CURRENT" }
                if ($Branch -eq "ALL" -or $Branch -eq $branchValue) {
                    $obj = [PSCustomObject]@{
                        Version = $version
                        Branch = $branchValue
                    }
                    $output += $obj
                }
            }
            return $output
        } else {
            # Return only the versions
            return $versions
        }
    } elseif ($VersionAndPath) {
        $output = @()
        foreach ($version in $versions) {
            $branchValue = if ($version.StartsWith("0")) { "OLD" } else { "CURRENT" }
            if ($Branch -eq "ALL" -or $Branch -eq $branchValue) {
                $path = $versionDirectoryMap[$version]
                $obj = [PSCustomObject]@{
                    Version = $version
                    Path = $path
                }
                $output += $obj
            }
        }
        return $output
    } else {
        # Default behavior, return the full PSCustomObject
        $output = @()
        foreach ($version in $versions) {
            $branchValue = if ($version.StartsWith("0")) { "OLD" } else { "CURRENT" }
            if ($Branch -eq "ALL" -or $Branch -eq $branchValue) {
                $path = $versionDirectoryMap[$version]

                $obj = [PSCustomObject]@{
                    Version = $version
                    Branch = $branchValue
                    Path = $path
                }

                $output += $obj
            }
        }
        return $output
    }

}



