function New-GitHubRepo {

    Param (
        [Parameter(Mandatory)]
        [String] $Folder,
        [String] $RepoName,
        [String] $Description,
        [String] $Homepage,
        [Switch] $Public,
        [Switch] $Browse
    )

    $sep = [System.IO.Path]::DirectorySeparatorChar
    if (-not($Folder.EndsWith($sep))) {
        $Folder += $sep
    }

    if(-not(Confirm-FolderIsGitRepository -Folder $Folder)){
        throw "$Folder is not a git repository."
    }

    if(-not(Test-Path -Path $(Join-Path $Folder 'LICENSE') -PathType Leaf)){
        $MITLicensePath = "D:\Dev\Powershell\VSYSModules\VSYSDevOps\Templates\LICENSE\MIT\LICENSE"
        $FinalPath = [System.IO.Path]::Combine($Folder, 'LICENSE')
        Copy-Item -LiteralPath $MITLicensePath -Destination $FinalPath -Force
    }

    try {
        $GHCmd = Get-Command gh.exe -CommandType Application
    } catch {
        throw "gh.exe (GitHub CLI) isn't available in PATH. Aborting."
    }

    $ghargs = @()
    if($Description) { $ghargs += '-d', $Description }
    if($Public) { $ghargs += '--public' } else { $ghargs += '--private' }
    $ghargs += '-h', $Homepage
    $ghargs += '--disable-wiki', '--source=.', '--push'

    & $GHCmd repo create $RepoName $ghargs
    if($Browse) { & $GHCmd browse | Out-Null }

}