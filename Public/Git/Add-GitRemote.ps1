function Add-GitRemote {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Folder,

        [Parameter(Mandatory)]
        [string] $RemoteName,

        [Parameter(Mandatory)]
        [string] $RemoteUrl
    )

    # Validate the remote URL
    if (-not ($RemoteUrl.StartsWith("http://") -or $RemoteUrl.StartsWith("https://") -or $RemoteUrl.StartsWith("git@"))) {
        Write-Error "The remote URL is not valid. It must start with http://, https://, or use the SSH format (git@)."
        return
    }

    # Check for spaces in the remote name
    if ($RemoteName -match '\s') {
        Write-Error "The remote name cannot contain spaces."
        return
    }

    # Navigate to the repository's folder
    Push-Location -Path $Folder -ErrorAction Stop

    try {
        # Check if the folder is a Git repository
        $gitFolderCheck = git rev-parse --is-inside-work-tree 2>&1
        if ($gitFolderCheck -ne 'true') {
            Write-Warning "The folder specified is not a git repository."
            return
        }

        # Check if the remote already exists
        $existingRemotes = git remote
        if ($RemoteName -in $existingRemotes) {
            Write-Warning "A remote with the name '$RemoteName' already exists."
            return
        }

        # Add the remote
        git remote add $RemoteName $RemoteUrl

        # Output a PSObject with the remote name and URL
        $result = [PSCustomObject]@{
            RemoteName = $RemoteName
            RemoteURL = $RemoteUrl
            ActionPerformed = "Added"
        }
        Write-Output $result
    }
    catch {
        Write-Error "An error occurred: $_"
    }
    finally {
        # Return to the original directory
        Pop-Location
    }
}
