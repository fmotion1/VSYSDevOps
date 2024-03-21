using namespace System.Management.Automation
class GitignoreTemplates : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return Get-GitignoreTemplates | ForEach-Object { $_.Name }
    }
}
function Save-GitignoreToFolder {

    [CmdletBinding(DefaultParameterSetName="Template")]

    param (

        [Parameter(Mandatory,ValueFromPipeline)]
        [string] $Folder,

        [Parameter(Mandatory=$false,ParameterSetName='Template',ValueFromPipelineByPropertyName)]
        [ValidateSet([GitignoreTemplates])]
        [String] $Template = '',

        [Parameter(Mandatory,ParameterSetName='File',ValueFromPipelineByPropertyName)]
        [String] $File,

        [Parameter(Mandatory=$false)]
        [Switch] $Force

    )

    process {

        if(-not(Test-Path -LiteralPath $Folder -PathType Container)){
            throw "-Folder passed ($Folder) does not exist on disk."
        }

        $GitignoreDestination = Join-Path $Folder '.gitignore'
        $GitignoreExists = Test-Path -LiteralPath $GitignoreDestination -PathType Leaf
        $GitignoreSource = $null

        if($GitignoreExists) {
            if(-not$Force){
                throw ".gitignore already exists. To replace it, specify the -Force parameter."
            }
        }

        if($PSCmdlet.ParameterSetName -eq 'Template'){

            if($Template -eq ''){
                $Template = Get-DevOpsUserConfigSetting -Key Templates.Gitignore.DefaultTemplate
            }

            $GitignoreTemplates = Get-GitignoreTemplates
            foreach ($T in $GitignoreTemplates) {
                if($T.Name -eq $Template){
                    $GitignoreSource = $T.File
                    break
                }
            }

            if([String]::IsNullOrEmpty($GitignoreSource)){
                throw "Can't find gitignore template ($GitignoreTemplate). Something is wrong."
            }
        }
        else{
            if(-not(Test-Path -LiteralPath $File -PathType Leaf)){
                throw "-File supplied doesn't exist."
            }
            $GitignoreSource = $File
        }

        [IO.File]::Copy($GitignoreSource, $GitignoreDestination, $true)

    }
}

