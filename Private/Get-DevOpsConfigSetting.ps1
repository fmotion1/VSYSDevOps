using namespace System.Management.Automation
class ModuleConfigSetting : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return $script:DevOpsConfigKeys
    }
}
function Get-DevOpsConfigSetting {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory,Position=0)]
        [ValidateSet([ModuleConfigSetting])]
        [string] $Key
    )

    return $script:DevOpsConfigData."${Key}"

}
