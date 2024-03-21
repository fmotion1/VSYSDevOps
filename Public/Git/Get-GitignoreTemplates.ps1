function Get-GitignoreTemplates {

    $Templates = $script:TemplatesPath
    $GitignoreTemplate = Get-DevOpsConfigSetting -Key System.Templates | ForEach-Object {$_} | Where-Object {$_.name -eq 'Gitignore'}
    $GitignoreTemplateFolder = Join-Path $Templates -ChildPath $GitignoreTemplate.path
    $GitignoreMetadata = Join-Path $GitignoreTemplateFolder -ChildPath 'metadata.json'
    $MetadataJSON = Get-Content -Path $GitignoreMetadata -Raw
    $MetadataObject = $MetadataJSON | ConvertFrom-Json

    $GitignoreDetails = ($MetadataObject.templates) | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.name
            File = Join-Path $GitignoreTemplateFolder -ChildPath ($_.file)
            Description = $_.description
        }
    }

    return $GitignoreDetails | Sort-Object -Descending
}