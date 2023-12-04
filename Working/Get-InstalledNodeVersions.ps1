function Get-InstalledNodeVersions {
    [CmdletBinding()]
    param (
        [string]$path
    )

    if (Test-Path $path) {
        $nodeInfo = Get-ItemProperty -Path $path
        return @{
            Version = $nodeInfo.Version
            InstallPath = $nodeInfo.InstallPath
        }
    } else {
        return $null
    }
}

# Attempt to retrieve Node.js info from 32-bit and 64-bit registry paths
$nodeInfo32bit = Get-InstalledNodeVersions -path 'HKLM:\SOFTWARE\Node.js'
$nodeInfo64bit = Get-InstalledNodeVersions -path 'HKLM:\SOFTWARE\Wow6432Node\Node.js'

# Output the results
if ($null -ne $nodeInfo32bit) {
    "32-bit Node.js found: Version $($nodeInfo32bit.Version), Install Path: $($nodeInfo32bit.InstallPath)"
}

if ($null -ne $nodeInfo64bit) {
    "64-bit Node.js found: Version $($nodeInfo64bit.Version), Install Path: $($nodeInfo64bit.InstallPath)"
}

if ($null -eq $nodeInfo32bit -and $null -eq $nodeInfo64bit) {
    "No Node.js installations found in the registry."
}
