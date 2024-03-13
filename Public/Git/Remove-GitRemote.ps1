function Remove-GitRemote {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory)]
        [string] $Folder,

        [Parameter(Mandatory)]
        [string] $RemoteName
    )

    if ($PSCmdlet.ShouldProcess("Git Remote '$RemoteName'", 'Remove')) {
        # Navigate to the repository's folder
        Push-Location -Path $Folder -ErrorAction Stop

        try {
            # Check if the folder is a Git repository
            $gitFolderCheck = git rev-parse --is-inside-work-tree 2>&1
            if ($gitFolderCheck -ne 'true') {
                Write-Warning "The folder specified is not a git repository."
                return
            }

            # Check if the remote exists
            $existingRemotes = git remote
            if ($RemoteName -notin $existingRemotes) {
                Write-Warning "A remote with the name '$RemoteName' does not exist."
                return
            }

            # Remove the remote
            git remote remove $RemoteName

            # Output a PSObject indicating the removal
            $result = [PSCustomObject]@{
                RemoteName = $RemoteName
                RemoteURL = $RemoteUrl
                ActionPerformed = "Removed"
            }
            Write-Output $result
        } catch {
            Write-Error "An error occurred: $_"
        } finally {
            # Return to the original directory
            Pop-Location
        }
    }

}
