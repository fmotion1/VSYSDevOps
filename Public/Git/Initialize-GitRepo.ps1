using namespace System.Management.Automation
class GitignoreTemplates : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $GitignoreTemplates = Get-GitignoreTemplates | ForEach-Object { $_.Name }
        return $GitignoreTemplates
    }
}
function Initialize-GitRepo {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [String] $Folder,

        [String] $BranchName = 'main',

        [Parameter(ValueFromPipelineByPropertyName)]
        [String] $CommitMessage = 'Initial commit.',

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet([GitignoreTemplates])]
        [String] $GitignoreTemplate = '',

        [Switch] $AddAndCommit,
        [Switch] $NavigateToFolder
    )

    begin {
        try {
            $GitCmd = Get-Command git.exe -CommandType Application
        } catch {
            Write-Error "Can't find 'git.exe' in PATH. Is git installed?"
            return
        }
    }

    process {

        if(-not(Test-Path -LiteralPath $Folder -PathType Container)){
            Write-Error "-Folder passed ($Folder) does not exist on disk."
            return
        }

        $IsGitRepo = Confirm-FolderIsGitRepository -Folder $Folder
        if($IsGitRepo){
            Write-Error "Folder is already a git repository."
            return
        }

        $GitignoreDestination = Join-Path -Path $Folder -ChildPath '.gitignore'
        $GitignoreExists = Test-Path -LiteralPath $GitignoreDestination -PathType Leaf
        if(-not$GitignoreExists){
            if($GitignoreTemplate -eq ''){
                $GitignoreTemplate = (Get-DevOpsUserConfigSetting -Key DefaultGitignoreTemplate)
            }
            Save-GitignoreToFolder -Folder $Folder -Template $GitignoreTemplate | Out-Null
        }

        Push-Location $Folder -StackName GITINIT

        $GitParams1 = 'init', '-b', "$BranchName"
        & $GitCmd $GitParams1

        if($AddAndCommit){
            $GitParams2 = 'add', '.'
            $GitParams3 = 'commit', '-m', "$CommitMessage"
            & $GitCmd $GitParams2
            & $GitCmd $GitParams3
        }

        if(-not$NavigateToFolder){
            Pop-Location -StackName GITINIT | Out-Null
        }


    }
}