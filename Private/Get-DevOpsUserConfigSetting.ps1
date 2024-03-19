using namespace System.Management.Automation
class ModuleUserConfigSetting : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return $script:DevOpsUserConfigKeys
    }
}
function Get-DevOpsUserConfigSetting {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory,Position=0)]
        [ValidateSet([ModuleUserConfigSetting])]
        [string] $Key
    )

    $ConfigData = $script:DevOpsUserConfigData
    return $ConfigData."$Key"

}
