function Get-GitRepoOriginAndBranch {
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string] $Folder
    )

    process {

        if(-not(Confirm-FolderIsGitRepository -Folder $Folder)){
            return $null
        }

        $GitCMD = Get-Command git.exe -CommandType Application
        $Params = '-C', $Folder, 'remote', 'get-url', 'origin'
        $OriginURL = & $GitCMD $Params

        if([String]::IsNullOrEmpty($OriginURL)){
            throw "$Folder is a repo, but has no origin. Aborting"
        }

        $Branch = & $GitCMD -C $Folder rev-parse --abbrev-ref HEAD

        [PSCustomObject]@{
            OriginURL = $OriginURL
            BranchName = $Branch
        }
    }
}

