function Update-NPMGlobalPackagesAllVersions {
    begin {

        $NodeVersions = Get-NVMInstalledNodeVersions -VersionOnly
        
    }
    process {

        Write-SpectreHost -Message "About to update all global packages for [white]ALL versions of NodeJS![/]"
        Write-Host "`n"
        Write-SpectreHost -Message "Be careful with this command as it may introduce breaking changes. Quit now if you don't want to do this."
        Write-Host "`n"

        Write-Host -NoNewLine 'Press any key to continue with the operation.'
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

        $NPMCmd = Get-Command npm.cmd
        & $NPMCmd update -g
    }
}