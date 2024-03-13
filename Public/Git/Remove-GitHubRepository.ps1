function Remove-GitHubRepository {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $Folder
    )

    Push-Location -Path $Folder -StackName RemoveGH

    Clear-Host

    try {
        $GHCmd = Get-Command gh.exe -CommandType Application
    } catch {
        throw "gh.exe (GitHub CLI) isn't available in PATH. Aborting."
    }

    $isGitRepo = Confirm-FolderIsGitRepository -Folder $Folder
    if(-not$isGitRepo){
        Write-SpectreHost "[#FFFFFF]  Passed folder is not a Git repository."
        exit
    }

    $isGitHubRepo = Confirm-FolderIsGithubRepo -Folder $Folder
    if(-not$isGitHubRepo){
        Write-SpectreHost "[#FFFFFF]  Passed folder is not a GitHub repository."
        exit
    }

    $repoObj = Get-GitRepoOriginAndBranch -Folder $Folder
    $repoOrigin = $repoObj.OriginURL
    $repoName = $repoOrigin -replace '^.+\/(.+?)(\.git)?$','$1'

    Write-Host ""
    $comfirmDeleteSplat = @{
        Prompt = "[#FFFFFF]  Are you sure you want to delete the GitHub repository '$repoName'? This action cannot be undone.[/]"
        DefaultAnswer = 'none'
    }
    $confirmation = Read-SpectreConfirm @comfirmDeleteSplat

    if ($confirmation -ne 'True') {
        Write-SpectreHost "[#636568]  Repository deletion cancelled.[/]"
        exit
    }

    try {
        $GHParams = 'repo','delete',"$repoName",'--yes'
        & $GHCmd $GHParams
    }
    catch {
        throw "Unknown error deleting the GitHub repository via gh.exe."
    }

    Pop-Location -StackName RemoveGH

    [PSCustomObject]@{
        RepoName = $repoName
        Success = $true
    }

}
