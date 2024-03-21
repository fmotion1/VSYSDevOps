function Get-LicenseTemplates {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [ValidateSet('Object','LicenseName','LicensePath','LicenseVariables','LicenseVariableCount', IgnoreCase = $true)]
        [String] $ReturnType = 'Object'
    )

    begin{

        $LicenseTemplatesData = Get-LicenseTemplateData

    }

    process {

        foreach ($LicenseTemplate in $LicenseTemplatesData) {
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
        }
    }
}