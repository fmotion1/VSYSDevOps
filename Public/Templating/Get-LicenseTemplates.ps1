function Get-LicenseTemplates {

    $Templates = Get-DevOpsConfigSetting -Key 'TemplatesPath'
    $LicenseTemplates = Join-Path $Templates -ChildPath '\license\'

    $LicenseFolders = Get-ChildItem -LiteralPath $LicenseTemplates -Directory
    $LicenseDetails = $LicenseFolders | ForEach-Object {

        $FolderPath = $_.FullName
        $MetadataFile = Join-Path -Path $FolderPath -ChildPath "metadata.json"
        if (-not(Test-Path -LiteralPath $MetadataFile -PathType Leaf)) {
            throw "Metadata file is missing for this license. ($FolderPath)"
        }
        $MetadataJSON = Get-Content -Path $MetadataFile -Raw
        $MetadataObject = $MetadataJSON | ConvertFrom-Json

        $LicenseName = $MetadataObject.name
        $LicenseVariables = $MetadataObject.variables

        [PSCustomObject]@{
            Name = $LicenseName
            ID = $_.Name
            Folder = $_.FullName
            LicenseFile = (Join-Path $_.FullName -ChildPath 'LICENSE')
            Variables = $LicenseVariables
        }
    }

    return $LicenseDetails | Sort-Object -Descending

}