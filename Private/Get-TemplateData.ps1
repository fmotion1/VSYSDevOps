using namespace System.Management.Automation
class TemplateNames : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return $script:TemplatesDataObject | ForEach-Object { $_.name }
    }
}

function Get-TemplateData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [ValidateSet([TemplateNames])]
        [String[]] $Template
    )

    begin {
        $TemplatesData = $script:TemplatesDataObject
    }

    process {

        foreach($Temp in $Template){

            foreach ($T in $TemplatesData){

                if($T.name -eq $Temp){
                    $TemplatePath = Join-Path -Path $script:TemplatesPath -ChildPath $T.path
                    $returnObj = [PSCustomObject]@{
                        Name             =  $T.name
                        Folder           =  $T.path
                        Path             =  $TemplatePath
                        Description      =  $T.description
                    }
                    if($T.metadata){
                        $MetadataPath = Join-Path -Path $script:TemplatesPath -ChildPath $T.metadata
                        $returnObj | Add-Member -NotePropertyName 'Metadata' -NotePropertyValue $MetadataPath | Out-Null
                    }
                    if($T.exportedFilename){
                        $returnObj | Add-Member -NotePropertyName 'ExportedFilename' -NotePropertyValue $T.exportedFilename | Out-Null
                    }
                    $returnObj
                    break
                }
            }
        }
    }
}