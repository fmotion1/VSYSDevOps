using namespace System.Management.Automation

class NodeVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-InstalledNodeVersionsCompleter
        return $v
    }
}
function Get-NodeGlobalPackagesByVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateSet([NodeVersions])]
        [String[]]
        $Versions,

        [Parameter(Mandatory=$false)]
        [Switch]
        $OmitDependencies
    )

    process {
        $NVMCmd = Get-Command nvm -CommandType Application
        & $NVMCmd use $Version

        $NPMCmd = Get-Command npm.cmd
        if($OmitDependencies) { & $NPMCmd list -g --depth=0 }
        else { & $NPMCmd list -g }
    }
}


