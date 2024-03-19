function Get-LicenseTemplate {

    param (
        [Parameter(Mandatory)]
        $Template,
        [ValidateSet('Object','LicenseName','LicenseVariables','LicenseVariableCount', IgnoreCase = $true)]
        [String] $ReturnType = 'Object'
    )

    $LicenseTemplatesData = $script:LicenseTemplateData

    foreach ($LicenseTemplate in $LicenseTemplatesData) {

        if($LicenseTemplate.LicenseName -eq $Template) {

            if($ReturnType -eq 'Object'){
                $LicenseObject = [PSCustomObject]@{
                    LicenseName          =  $LicenseTemplate.LicenseName
                    LicenseFolder        =  $LicenseTemplate.LicenseFolder
                    LicensePath          =  $LicenseTemplate.LicensePath
                    LicenseVariableCount =  $LicenseTemplate.LicenseVariableCount
                    LicenseVariables     =  $LicenseTemplate.LicenseVariables
                }

                return $LicenseObject
            }
            elseif($ReturnType -eq 'LicenseName'){
                return $LicenseTemplate.LicenseName
            }
            elseif($ReturnType -eq 'LicenseVariables'){
                return $LicenseTemplate.LicenseVariables
            }
            elseif($ReturnType -eq 'LicenseVariableCount'){
                $LicenseTemplate.LicenseVariableCount
            }
        }
    }
}