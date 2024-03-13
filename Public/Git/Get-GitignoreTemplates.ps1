function Get-GitignoreTemplates {

    $Templates = Get-DevOpsConfigSetting -Key 'TemplatesFolder'
    $GitignoreTemplates = Join-Path $Templates -ChildPath '\gitignore\'
    $GitignoreMetadata = Join-Path $GitignoreTemplates -ChildPath 'metadata.json'
    $MetadataJSON = Get-Content -Path $GitignoreMetadata -Raw
    $MetadataObject = $MetadataJSON | ConvertFrom-Json

    $GitignoreDetails = ($MetadataObject.templates) | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.name
            File = Join-Path $GitignoreTemplates -ChildPath ($_.file)
            Description = $_.description
        }
    }

    return $GitignoreDetails | Sort-Object -Descending
}