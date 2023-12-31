@{
    RootModule = "VSYSDevOps.psm1"
    ModuleVersion = '1.0.0'
    GUID = 'ee9012b6-e539-593b-852b-1c68e2f9af70'
    Author = 'futur'
    CompanyName = 'Futuremotion'
    Copyright = '(c) Futuremotion. All rights reserved.'

    CompatiblePSEditions = @('Core')

    Description = 'Provides development automation functions.'
    PowerShellVersion = '7.0'

    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    ScriptsToProcess = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    FileList = @()

    # Leave commented out to import into any host.
    # PowerShellHostName = ''

    RequiredModules = @('PwshSpectreConsole')
    RequiredAssemblies = "$PSScriptRoot\Lib\PythonVenvDetails.dll"

    FunctionsToExport = 'Get-NodeGlobalPackages',
                        'Get-InstalledNodeVersionsWithNVM',
                        'Get-InstalledPythonVersionsPYLauncher',
                        'Get-PythonVENVDetails',
                        'Save-DotnetAssemblyTemplate',
                        'Save-DotnetConsoleAppTemplate',
                        'Save-GitignoreToFolder',
                        'Save-LicenseToFolder',
                        'Update-NodeGlobalPackagesPerVersion',
                        'Install-NodeGlobalPackages',
                        'Install-PythonGlobalPackages',
                        'Uninstall-NodeGlobalPackages',
                        'Confirm-NPMPackageExistsInRegistry',
                        'Confirm-PythonPyPiPackageExists',
                        'Save-LicenseToFolder',
                        'Get-LicenseTemplates',
                        'Get-InstalledNodeVersionsCompleter',
                        'Get-ActiveNodeVersionWithNVM',
                        'Get-LinuxWSLDistributionInfo'
                        

    PrivateData = @{
        PSData = @{
            Tags = @('Development', 'Programming', 'DevOps', 'Optimization')
            LicenseUri = 'https://github.com/fmotion1/VSYSDevOps/blob/main/LICENSE'
            ProjectUri = 'https://github.com/fmotion1/VSYSDevOps'
            IconUri = ''
            ReleaseNotes = '1.0.0: (10/31/2023) - Initial Release'
        }
    }
}

