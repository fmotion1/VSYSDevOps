using namespace System.Management.Automation

class UserConfigKeys : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $Keys = 'LicenseOwner',
                'LicenseYear',
                'LicenseEmail',
                'UserName',
                'UserHomepage',
                'DefaultLicense',
                'DefaultGitignoreTemplate',
                'DefaultGitBranch'
        return $Keys
    }
}
function Get-DevOpsUserConfigSetting {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory,Position=0)]
        [ValidateSet([UserConfigKeys])]
        [string] $Key
    )

    process {

        $ErrorActionPreference = 'Stop'
        $ModuleBase = $MyInvocation.MyCommand.Module.ModuleBase
        $UserConfig = Join-Path -Path $ModuleBase -ChildPath 'userconfig.json'

        if (Test-Path -LiteralPath $UserConfig -PathType Leaf) {
            try {
                $ConfigJSON = Get-Content -Path $UserConfig -Raw
                $ConfigObject = $ConfigJSON | ConvertFrom-Json
                $ConfigKey = $ConfigObject.$Key
                if([String]::IsNullOrEmpty($ConfigKey)){
                    Write-Error "Error getting user-configuration key ($Key). It's null or empty."
                    return
                }
                else{
                    Write-Output $ConfigObject.$Key
                }

            }
            catch {
                Write-Error -Message "Something went wrong getting user configuration. $($_.Exception.Message)"
                return
            }
        }
        else {
            Write-Error -Message 'User configuration file not found.'
            return
        }
    }
}