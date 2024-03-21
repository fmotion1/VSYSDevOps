function Get-LicenseTemplateData {

    param()

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

    return $LicenseTemplatesArr

}

