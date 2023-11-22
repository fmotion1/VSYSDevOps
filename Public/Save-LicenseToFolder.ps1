using namespace System.Management.Automation

class AvailableLicenseTemplates : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-LicenseTemplates | Sort-Object -Descending
        return $v.Name
    }
}

function Save-LicenseToFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Folder,

        [Parameter(Mandatory)]
        [ValidateSet([AvailableLicenseTemplates])]
        $LicenseType,

        [Parameter(Mandatory=$false)]
        [Switch]
        $Force
    )

    begin {

        $LicMaster = Get-LicenseTemplates | Sort-Object -Descending
        foreach ($idx in $LicMaster) {
            if($idx.Name -eq $LicenseType){
                $CurrentLicense = $idx
                break
            }
        }
    }

    process {

        $LicenseExists       = Test-Path -LiteralPath (Join-Path $Folder LICENSE) -PathType Leaf
        $LicenseTemplatePath = Join-Path $CurrentLicense.Path 'LICENSE'

        If((!$LicenseExists) -or $Force){
            if (!(Test-Path $Folder -PathType Container)) {
                New-Item -ItemType Directory -Path $Folder -Force | Out-Null
            }
            Copy-Item $LicenseTemplatePath -Destination $Folder -Force
        }
    }
}
