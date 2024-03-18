function Get-LicenseTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Template
    )

    process {

        $DevOpsTemplates = Get-DevOpsConfigSetting -Key TemplatesPath
        $LicenseTemplatesPath = Join-Path -Path $DevOpsTemplates -ChildPath 'license'


        foreach ($T in $Template) {

        }
    }
}