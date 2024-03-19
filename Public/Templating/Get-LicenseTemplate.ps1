using namespace System.Management.Automation
class LicenseTemplateName : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return $script:LicenseTemplateKeys
    }
}
function Get-LicenseTemplate {

    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [ValidateSet([LicenseTemplateName])]
        [String[]] $Template,

        [ValidateSet('Object','LicenseName','LicensePath','LicenseVariables','LicenseVariableCount', IgnoreCase = $true)]
        [String] $ReturnType = 'Object'
    )

    begin{

        $LicenseTemplatesData = $script:LicenseTemplateData

    }

    process {
        foreach($Temp in $Template){

            foreach ($LicenseTemplate in $LicenseTemplatesData) {
                if($LicenseTemplate.LicenseName -eq $Temp) {
                    if($ReturnType -eq 'Object'){
                        $LicenseObject = [PSCustomObject]@{
                            LicenseName          =  $LicenseTemplate.LicenseName
                            LicenseFolder        =  $LicenseTemplate.LicenseFolder
                            LicensePath          =  $LicenseTemplate.LicensePath
                            LicenseVariables     =  $LicenseTemplate.LicenseVariables
                            LicenseVariableCount =  $LicenseTemplate.LicenseVariableCount
                        }
                        $LicenseObject
                    }
                    elseif($ReturnType -eq 'LicensePath'){
                        $LicenseTemplate.LicenseName
                    }
                    elseif($ReturnType -eq 'LicenseName'){
                        $LicenseTemplate.LicenseName
                    }
                    elseif($ReturnType -eq 'LicenseVariables'){
                        $LicenseTemplate.LicenseVariables
                    }
                    elseif($ReturnType -eq 'LicenseVariableCount'){
                        $LicenseTemplate.LicenseVariableCount
                    }
                    break
                }
            }
        }
    }
}