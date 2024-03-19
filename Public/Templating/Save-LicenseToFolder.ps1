﻿using namespace System.Management.Automation

class AvailableLicenseTemplates : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-LicenseAllTemplates -OnlyKeys | Sort-Object -Descending
        return $v.Name
    }
}

function Save-LicenseToFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [String] $Folder,

        [Parameter(Mandatory)]
        [ValidateSet([AvailableLicenseTemplates],ErrorMessage="License template specified does not exist.")]
        [String] $LicenseType,

        [Parameter(Mandatory=$false)]
        [Switch] $Force

    )

    process {

        if (-not(Test-Path $Folder -PathType Container)) {
            Write-Error -Message "Passed -Folder does not exist ($Folder). Aborting."
            return
        }

        $AllLicenseTemplates = Get-LicenseAllTemplates | Sort-Object -Descending

        foreach ($Template in $AllLicenseTemplates) {
            if($Template.LicenseName -eq $LicenseType){
                $CurrentLicense = $Template
                break
            }
        }

        $LicenseDestination = Join-Path $Folder -ChildPath 'LICENSE'
        $LicenseExists = Test-Path -LiteralPath $LicenseDestination -PathType Leaf
        $LicenseTemplatePath = $CurrentLicense.LicensePath
        $LicenseVariables = $CurrentLicense.LicenseVariables

        If($LicenseExists){
            if(-not$Force){
                Write-Error -Message "License already exists in this folder. Specify -Force to overwrite."
                return
            }
        }

        [IO.File]::Copy($LicenseTemplatePath, $LicenseDestination, $true) | Out-Null

        if($LicenseVariables.Count -gt 0){
            try {

                $LicenseContent = Get-Content -Path $LicenseDestination -Raw

                foreach ($Var in $LicenseVariables) {
                    $VariablePlaceholder = [regex]::Escape($Var.VariablePattern)
                    $ToReplace = Get-DevOpsUserConfigSetting -Key ($Var.VariableUserConfig)
                    $LicenseContent = $LicenseContent -replace $VariablePlaceholder, $ToReplace
                }
                Set-Content -LiteralPath $LicenseDestination -Value $LicenseContent -Force
            }
            catch {
                throw "Something went wrong setting license content. Destination file is: $LicenseDestination"
            }
        }
    }
}

