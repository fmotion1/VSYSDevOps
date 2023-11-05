using namespace System.Management.Automation

class NVMVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $R = @(& nvm root)
        [String]$NVMRoot = $R[1]
        $NVMRoot = $NVMRoot -replace 'Current Root: '
        $VersionsSplat = @{
            LiteralPath = $NVMRoot
            Directory   = $true
        }
        return $(Get-ChildItem @VersionsSplat | % { $_.Name })
    }
}
function Update-NPMGlobalPackagesPerVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateSet([NVMVersions])]
        [String]
        $Version
    )
    begin {
        $NVMCmd = Get-Command nvm.exe
        $Params = 'use', $Version
        & $NVMCmd $Params
    } 
    process {
        Write-SpectreHost -Message "About to update all global packages for [white]Node $Version[/]"
        Read-Host "Press any key to continue with the operation."
        $NPMCmd = Get-Command npm.cmd
        & $NPMCmd update -g
    }
}