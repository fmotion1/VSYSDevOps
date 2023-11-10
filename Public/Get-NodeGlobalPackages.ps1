function Get-NodeGlobalPackages {
    # Ensure NVM is installed and available in the current session
    if (-not (Get-Command nvm.exe)) {
        Write-Error "NVM does not appear to be installed or is not in the PATH."
        return
    }

    $Versions = Get-NodeVersionsWithNVM -VersionOnly

    foreach ($v in $Versions) {

        Write-SpectreHost "[white]Listing globally installed NPM packages for Node version: [/][#6A90FF]v$v[/]"

        $NVMCmd = Get-Command nvm.exe
        & $NVMCmd use $v > $null

        $NPMCmd = Get-Command npm.cmd
        $globalPackages = & $NPMCmd list -g --depth=0

        Write-SpectreHost "Node version: [white]v$v[/]"
        $Packages = ($globalPackages -split "\r?\n") | % {
            if([String]::IsNullOrEmpty($_)){
                return
            }
            $_
        }
        foreach ($Package in $Packages) {
            Write-SpectreHost $Package
        }
        #Write-Output $globalPackages
        Write-Output "------------------------------------------------"
    }
}
