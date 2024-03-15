function Get-DevOpsUserConfigSetting {

    [CmdletBinding()]
    [OutputType([string])]

    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [string] $Key
    )

    process {

        $ErrorView

        $ErrorActionPreference = 'Stop'
        $ModuleBase = $MyInvocation.MyCommand.Module.ModuleBase
        $UserConfig = Join-Path -Path $ModuleBase -ChildPath 'userconfig.json'

        if (Test-Path -LiteralPath $UserConfig -PathType Leaf) {
            try {
                $ConfigObject = Get-Content -Path $UserConfig -Raw | ConvertFrom-Json
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



