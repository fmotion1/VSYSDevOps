using namespace System.Management.Automation

## TODO: Generalize this function more to accept multiple versions
## Get-NodeGlobalInstalls -Versions 21.1.0, 18.18.2
## Get-NodeGlobalInstalls -Versions All

class NodeVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-NodeVersions -VersionOnly
        return $v
    }
}
function Get-NodeGlobalPackagesByVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateSet([NodeVersions])]
        [String]
        $Version,

        [Parameter(Mandatory=$false)]
        [Switch]
        $OmitDependencies
    )

    begin {
        $NVMCmd = Get-Command nvm.exe
        $Params = 'use', $Version
        & $NVMCmd $Params
    } 
    
    process {
        $NPMCmd = Get-Command npm.cmd
        if($OmitDependencies) { & $NPMCmd list -g --depth=0 }
        else { & $NPMCmd list -g }
    }
}


