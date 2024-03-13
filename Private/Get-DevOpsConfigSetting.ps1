﻿function Get-DevOpsConfigSetting {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory,Position=0)]
        [string] $Key
    )

    process {

        $ErrorActionPreference = 'Stop'
        $ModuleBase = $MyInvocation.MyCommand.Module.ModuleBase
        $ConfigFile = Join-Path -Path $ModuleBase -ChildPath 'Config.psd1'

        if (Test-Path -Path $ConfigFile) {
            try {
                $Config = Import-PowerShellDataFile -Path $ConfigFile
                Write-Output $Config.$Key
            }
            catch {
                Write-Error -Message $_.Exception.Message
            }
        }
        else {
            Write-Error -Message 'Config file not found!'
        }
    }

    end { }
}