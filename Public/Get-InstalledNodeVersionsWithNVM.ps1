using namespace System.Management.Automation

class NodeVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-InstalledNodeVersionsCompleter
        return $v
    }
}

function Get-InstalledNodeVersionsWithNVM {

    <#
    .SYNOPSIS
    This function returns the installed Node.js versions with Node Version Manager (NVM).
    
    .PARAMETER VersionOnly
    Optional switch to display only the version numbers of installed Node.js versions. If neither VersionOnly nor VersionAndPath are specified, default output will be used.
    
    .PARAMETER VersionAndPath
    Optional switch to display both the version numbers and installation paths of the installed Node.js versions.
    
    .PARAMETER FilterVersions
    Optional parameter specifying an array of specific versions to return, validated against installed Node.js versions.
    
    .PARAMETER Branch
    A string parameter to filter installations by branch. The accepted values are "CURRENT", "OLD", and "ALL". The default value is "ALL".
    
    .PARAMETER ShowBranch
    Optional switch that adds the branch column to the results if desired.
    
    .PARAMETER Table
    A switch parameter. When specified, the results will be formatted as a table for better readability.
    
    .PARAMETER TableBorder
    This parameter accepts a string representation of the desired style for the table border when displaying results in a table format.
    
    .EXAMPLE
    Get-InstalledNodeVersionsWithNVM -VersionAndPath -FilterVersions '12.18.3', '14.5.0' -Table
    
    This example retrieves the version and install path information for Node.js versions 12.18.3 and 14.5.0, and displays the results in a table format.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, HelpMessage="Display only versions.")]
        [switch] $VersionOnly,

        [Parameter(Mandatory=$false, HelpMessage="Display only versions and install paths.")]
        [switch] $VersionAndPath,

        [Parameter(HelpMessage="Return only specific versions.")]
        [string[]]
        [ValidateSet([NodeVersions])]
        $FilterVersions,

        [Parameter(HelpMessage="Display installations filtered by branch.")]
        [ValidateSet("CURRENT", "OLD", "ALL", IgnoreCase=$true)]
        [string] $Branch = "ALL",

        [Parameter(HelpMessage="Add the branch column to the results if desired.")]
        [switch] $ShowBranch,

        [Parameter(HelpMessage="Prettify the results with a table.")]
        [switch] $Table,

        [Parameter(HelpMessage="Change the style of the table border.")]
        [ValidateSpectreTableBorder()]
        [ArgumentCompletionsSpectreTableBorder()]
        [String] $TableBorder = "Square"
        
    )

    process {
        # Ensure VersionOnly and VersionAndPath are not used together
        if ($VersionOnly -and $VersionAndPath) {
            throw "VersionOnly and VersionAndPath cannot be used together."
        }
        
        # Retrieves the command for executing NVM from the system.
        $NVMCmd = Get-Command nvm.exe
        $NVMRoot = (& $NVMCmd root)[1] -replace 'Current Root: '

        # Retrieve all child directories starting with 'v' from the
        # NVM installation root directory, trim off the 'v' at the
        # start, and store the array of full directory paths in the
        # NodeDirsFull variable.
        $NodeDirsFull = ((Get-ChildItem -Path $NVMRoot -Filter 'v*' -Directory).FullName).TrimStart('v')
        
        # Gets the list of installed Node.js versions using the "list"
        # command in NVM, splits the result by new lines, removes any
        # empty or null values, and stores the clean list in
        # NodeVersions.
        $NodeVersions = (& $NVMCmd list) | % { $_ -split '\r?\n'} | % { if(![String]::IsNullOrEmpty($_)){ $_ } }
        
        # cleans up the NodeVersions array by removing extra
        # characters such as '*', '(', ')', any text within
        # parentheses, and leading/trailing spaces.
        $NodeVersions = (($NodeVersions -replace '\* ', '') -replace '\(([\w\s\-]+)\)', '').Trim()

        # Full path directories corresponding to different Node.js versions installed on your system.
        $directoryString = $NodeDirsFull
        # A collection of strings representing different Node.js versions installed on your system via NVM.
        $versionString   = $NodeVersions

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

        # Defines an array ($output) to store the desired output of
        # installed Node.js versions, their branches (either "OLD" or
        # "CURRENT"), and paths.
        $output = @()
        foreach ($version in $versions) {
            $branchValue = if ($version.StartsWith("0")) { "OLD" } else { "CURRENT" }
           
            if ($Branch -eq "ALL" -or $Branch -eq $branchValue) {
                
                # Retrieves the path associated with the current
                # version from the $versionDirectoryMap hashtable
                # and assigns it to the $path variable.
                $path = $versionDirectoryMap[$version]

                $obj = [PSCustomObject]@{
                    Version = $version
                    Branch = $branchValue
                    Path = $path
                }

                # Adjust the object based on switches
                if ($VersionOnly) {
                    if ($ShowBranch) {
                        $output += [PSCustomObject]@{
                            Version = $version
                            Branch = $branchValue
                        }
                    } else {
                        $output += [PSCustomObject]@{
                            Version = $version
                        }
                    }
                } elseif ($VersionAndPath) {
                    if ($ShowBranch) {
                        $output += [PSCustomObject]@{
                            Version = $version
                            Branch = $branchValue
                            Path = $path
                        }
                    } else {
                        $output += [PSCustomObject]@{
                            Version = $version
                            Path = $path
                        }
                    }
                } else {
                    $output += $obj
                }
            }
        }

        # Handles the visualization of output when the $Table switch is used.
        if ($Table) {
            # Prepare data for Format-SpectreTable
            $DataArr = @()
            foreach ($Property in $output) {
                $tempObj = [PSCustomObject]@{}
                foreach ($propName in $Property.PSObject.Properties.Name) {
                    $tempObj | Add-Member -Name $propName -Type NoteProperty -Value $Property.$propName
                }
                $DataArr += $tempObj
            }
            # Format-SpectreTable will take the data in $DataArr,
            # format it into a square-bordered table, and color the
            # border grey.
            Format-SpectreTable -Data $DataArr -Border $TableBorder -Color Grey35
        
        } else {
            # Return the final output.
            return $output
        }
    }
}



