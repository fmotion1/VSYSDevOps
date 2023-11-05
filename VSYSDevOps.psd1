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
    RequiredAssemblies = @('Lib\PythonVenvDetails.dll')

    FunctionsToExport = 'Get-NodeGlobalPackagesByVersion',
                        'Get-NodeGlobalPackages',
                        'Get-NodeVersions',
                        'Get-PythonVENVDetails',
                        'New-DotnetAssemblyTemplate',
                        'Save-GitignoreToFolder',
                        'Save-LicenseToFolder',
                        'Update-NodeGlobalPackagesForAllVersions',
                        'Update-NodeGlobalPackagesPerVersion',
                        'Install-NodeGlobalPackages',
                        'Uninstall-NodeGlobalPackages',
                        'Confirm-NPMPackageExistsInRegistry'
                        

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

