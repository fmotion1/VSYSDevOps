function Get-NodeGlobalPackages {
    # Ensure NVM is installed and available in the current session
    if (-not (Get-Command "nvm" -ErrorAction SilentlyContinue)) {
        Write-Error "NVM does not appear to be installed or is not in the PATH."
        return
    }

    # Get all installed Node versions using NVM
    $nodeVersions = & nvm list

    # Filter and clean up the version list
    $nodeVersions = $nodeVersions | Where-Object { $_ -match '^\s*\d+\.\d+\.\d+' } | ForEach-Object { $_.Trim() }

    # Iterate over each version to list global NPM packages
    foreach ($version in $nodeVersions) {
        Write-Host "Listing globally installed NPM packages for Node version: $version"

        # Use NVM to switch to the current version
        & nvm use $version > $null

        # List global NPM packages
        $NPMCmd = Get-Command npm.cmd
        $globalPackages = & $NPMCmd list -g --depth=0

        Write-Output "Node version: $version"
        Write-Output $globalPackages
        Write-Output "------------------------------------------------"
    }
}
