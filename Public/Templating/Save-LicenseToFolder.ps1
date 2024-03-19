using namespace System.Management.Automation

class AvailableLicenseTemplates : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return $script:LicenseTemplateKeys
    }
}

function Save-LicenseToFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [String] $Folder,

        [Parameter(Mandatory)]
        [ValidateSet([AvailableLicenseTemplates])]
        [String] $LicenseType,

        [Parameter(Mandatory=$false)]
        [Switch] $Force

    )

    begin {

        $LicenseTemplatesObj = $script:LicenseTemplatesObject
        $LicenseTemplatesArr = @()
        $LicenseTemplate = Get-DevOpsConfigSetting -Key System.Templates | ForEach-Object {$_} | Where-Object {$_.name -eq 'License File'}
        $LicenseFilename = $LicenseTemplate.exportedFilename

        foreach ($obj in $LicenseTemplatesObj) {

            $CurrentObj = [PSCustomObject][Ordered]@{
                LicenseName          =  $obj.name
                LicenseFolder        =  (Join-Path $script:LicenseTemplatesPath -ChildPath $obj.path)
                LicensePath          =  (Join-Path $script:LicenseTemplatesPath -ChildPath $obj.path -AdditionalChildPath $LicenseFilename)
                LicenseVariables     =  @()
                LicenseVariableCount =  0
            }

            foreach ($variable in $obj.variables){

                $VariableObject = [PSCustomObject]@{
                    VariableName        =  $variable.name
                    VariablePattern     =  $variable.variable
                    VariableUserConfig  =  $variable.userConfig
                    VariableDescription =  $variable.description
                }
                $CurrentObj.LicenseVariables += $VariableObject
                $CurrentObj.LicenseVariableCount += 1
            }

            $LicenseTemplatesArr += $CurrentObj
        }
    }


    process {

        if (-not(Test-Path $Folder -PathType Container)) {
            Write-Error -Message "Passed -Folder does not exist ($Folder). Aborting."
            return
        }

        foreach ($Template in $LicenseTemplatesArr) {
            if($Template.LicenseName -eq $LicenseType){
                $CurrentLicense = $Template
                break
            }
        }

        $LicenseDestination = Join-Path $Folder -ChildPath $LicenseFilename
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
                    $ToReplace = Get-DevOpsUserConfigSetting -Key $($Var.VariableUserConfig)
                    $LicenseContent = $LicenseContent -replace $VariablePlaceholder, $ToReplace
                }

                Set-Content -LiteralPath $LicenseDestination -Value $LicenseContent -Force
            }
            catch {
                throw "Something went wrong setting license content. Details: $_"
            }
        }
    }
}

