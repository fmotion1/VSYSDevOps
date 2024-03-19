function Get-LicenseAllTemplates {
    param (
        [Switch] $OnlyKeys
    )

    $LicenseTemplatesData = $script:LicenseTemplateData
    $LicenseTemplates = @()

    foreach ($LicenseTemplate in $LicenseTemplatesData) {
        $LicenseObject = [PSCustomObject]@{
            LicenseName = $LicenseTemplate.LicenseName
            LicenseFolder = $LicenseTemplate.LicenseFolder
            LicensePath = $LicenseTemplate.LicensePath
            LicenseVariableCount = $LicenseTemplate.LicenseVariableCount
            LicenseVariables = $LicenseTemplate.LicenseVariables
        }

        $LicenseTemplates += $LicenseObject
    }

    if ($OnlyKeys) {
        return $LicenseTemplates | ForEach-Object { $_.LicenseName }
    } else {
        return $LicenseTemplates | Sort-Object -Descending
    }
}