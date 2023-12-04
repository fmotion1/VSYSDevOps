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

    process {
        # Ensure VersionOnly and VersionAndPath are not used together
        if ($VersionOnly -and $VersionAndPath) {
            throw "VersionOnly and VersionAndPath cannot be used together."
        }

        $NVMCmd = Get-Command nvm.exe
        $NVMRoot = (& $NVMCmd root)[1] -replace 'Current Root: '
        $NodeDirsFull = ((Get-ChildItem -Path $NVMRoot -Filter 'v*' -Directory).FullName).TrimStart('v')
        $NodeVersions = (& $NVMCmd list) | % { $_ -split '\r?\n'} | % { if(![String]::IsNullOrEmpty($_)){ $_ } }
        $NodeVersions = (($NodeVersions -replace '\* ', '') -replace '\(([\w\s\-]+)\)', '').Trim()

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

        # Generate the output
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

                # Depending on switches, adjust the object accordingly
                if ($VersionOnly) {
                    if ($ShowBranch) {
                        $output += [PSCustomObject]@{
                            Version = $version
                            Branch = $branchValue
                        }
                    } else {
                        $output += $version
                    }
                } elseif ($VersionAndPath) {
                    $output += [PSCustomObject]@{
                        Version = $version
                        Path = $path
                    }
                } else {
                    $output += $obj
                }
            }
        }
        Write-Host "`$Table:" $Table -ForegroundColor Green
        Write-Host "Test" -ForegroundColor White
        if ($Table.IsPresent) {
            Write-Host "Test" -ForegroundColor White
            # Convert output to the format required by Format-SpectreTable
            $tableData = $output | ForEach-Object {
                $item = $_
                $item.PSObject.Properties | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_.Name
                        Value = $_.Value
                    }
                }
            }
            # Display as a table

            Format-SpectreTable -Data $tableData
        } else {
            # Return the output as is
            return $output
        }
    }
}



