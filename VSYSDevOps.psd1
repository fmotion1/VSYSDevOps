@{

    RootModule = "VSYSDevOps.psm1"
    ModuleVersion = '1.0.2'
    GUID = 'ee9012b6-e539-593b-852b-1c68e2f9af70'
    Author = 'Futuremotion'
    CompanyName = 'Futuremotion'
    Copyright = '(c) Futuremotion 2024-2025. All rights reserved.'

    CompatiblePSEditions = @('Core')

    Description = 'Provides development automation functions.'
    PowerShellVersion = '7.1'

    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    ScriptsToProcess = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    FileList = @()

    # Leave commented out to import into any host.
    # PowerShellHostName = ''

    RequiredModules    = @('PwshSpectreConsole')

    RequiredAssemblies = "$PSScriptRoot\Lib\PythonVENVObject.dll",
                         "$PSScriptRoot\lib\Ookii.Dialogs.WinForms.dll",
                         "$PSScriptRoot\lib\Microsoft.Toolkit.Uwp.Notifications.dll",
                         "$PSScriptRoot\lib\Microsoft.Windows.SDK.NET.dll",
                         "$PSScriptRoot\lib\WinRT.Runtime.dll",
                         "System.Drawing",
                         "System.Windows.Forms",
                         "PresentationCore",
                         "PresentationFramework",
                         "Microsoft.VisualBasic"

    FunctionsToExport =  'Convert-iTermColorsToINI',
                         'Start-CountdownTimer',
                         'Add-GitRemote',
                         'Confirm-FolderIsGithubRepo',
                         'Confirm-FolderIsGitRepository',
                         'Get-GitRepoOriginAndBranch',
                         'New-GithubRepo',
                         'Remove-GitHubRepository',
                         'Remove-GitOrigin',
                         'Remove-GitRemote',
                         'Save-GitignoreToFolder',
                         'Convert-PlaintextListToArray',
                         'Convert-CommaSeparatedListToPlaintextTable',
                         'Convert-JsonKeysToCommaSeparatedString',
                         'Convert-JsonKeysToLines',
                         'Split-StringByDelimiter',
                         'Split-StringByDelimiterAndCombineLines',
                         'Find-SeparatorInList',
                         'Confirm-NPMPackageExistsInRegistry',
                         'Get-ActiveNodeVersionWithNVM',
                         'Get-InstalledNodeGlobalPackages',
                         'Get-InstalledNodeVersionsCompleter',
                         'Get-InstalledNodeVersionsWithNVM',
                         'Get-LatestNodeWithNVM',
                         'Get-NodeGlobalPackages',
                         'Install-NodeGlobalPackages',
                         'Invoke-NPMCommandsOnNodeVersion',
                         'Uninstall-NodeGlobalPackages',
                         'Update-NodeGlobalPackagesPerVersion',
                         'Test-PathIsLikelyDirectory',
                         'Test-PathIsLikelyFile',
                         'Confirm-PythonFolderIsVENV',
                         'Confirm-PythonPyPiPackageExists',
                         'Get-PythonInstalledVersions',
                         'Get-MinicondaInstallDetails',
                         'Get-PythonVENVDetails',
                         'Install-PythonPredefinedVENV',
                         'Install-PythonGlobalPackages',
                         'Get-LicenseTemplates',
                         'Save-DotnetAssemblyTemplate',
                         'Save-DotnetConsoleAppTemplate',
                         'Save-LicenseToFolder',
                         'Save-PowershellGalleryNupkg',
                         'Format-Milliseconds',
                         'Convert-AudioToStemsWithDEMUCS',
                         'Copy-WindowsDirectoryStructure',
                         'Copy-WindowsPathToClipboard',
                         'Get-WindowsDefaultBrowser',
                         'Get-WindowsEnvironmentVariable',
                         'Get-WindowsEnvironmentVariables',
                         'Get-WindowsWSLDistributionInfo',
                         'Get-WindowsOpenDirectories',
                         'Get-WindowsOSArchitecture',
                         'Get-WindowsProcessOverview',
                         'Merge-FlattenDirectory',
                         'Move-FileToFolder',
                         'Move-FileToSubfolder',
                         'Open-WindowsExplorerTo',
                         'Register-WindowsDLLorOCX',
                         'Remove-WindowsInvalidFilenameCharacters',
                         'Rename-RandomizeFilenames',
                         'Request-WindowsAdminRights',
                         'Request-WindowsExplorerRefresh',
                         'Restart-WindowsExplorerAndRestore',
                         'Save-FilesToFolderByWord',
                         'Save-FolderToSubfolderByWord',
                         'Save-WindowsOpenDirectories',
                         'Save-RandomDataToFile',
                         'Save-RandomDataToFiles',
                         'Search-GoogleIt',
                         'Set-WindowsFolderIcon',
                         'Split-DirectoryContentsToSubfolders',
                         'Stop-AdobeBackgroundProcesses',
                         'Test-FileIsLocked',
                         'Update-WindowsEnvironmentVariables',
                         'Invoke-OpenFileDialog',
                         'Invoke-VBMessageBox',
                         'Invoke-GUIMessageBox',
                         'Invoke-OokiiInputDialog',
                         'Invoke-OokiiPasswordDialog',
                         'Invoke-OokiiTaskDialog',
                         'Invoke-SaveFileDialog',
                         'Invoke-OpenFolderDialog',
                         'Show-UWPToastNotification',
                         'Test-URLIsValid',
                         'Test-PathIsValid',
                         'ConvertTo-FlatObject',
                         'Get-FirstUniqueFileByDepth',
                         'Format-Bytes',
                         'Format-FileSize',
                         'Format-ObjectSortNumerical',
                         'Format-StringTitleCase',
                         'Get-Enum',
                         'Get-ModulePrivateFunctions',
                         'Get-RandomAlphanumericString',
                         'Get-UniqueFileOrFolderNameIfDuplicate',
                         'New-TempDirectory',
                         'Format-StringRemoveDiacritics',
                         'Save-Base64StringToFile',
                         'Save-FileHash',
                         'Test-WindowsIsAdmin',
                         'Test-PathIsUnsafe',
                         'Initialize-GitRepo',
                         'Join-StringByNewlinesWithDelimiter',
                         'Get-DevOpsConfigSetting',
                         'Get-DevOpsUserConfigSetting',
                         'Get-GitignoreTemplates',
                         'Use-PythonActivateVENVInFolder',
                         'Update-PythonPackagesInVENV',
                         'Update-PythonPIPInVENV',
                         'Update-PythonPIPGlobally',
                         'Use-PythonFreezeVENVToRequirements',
                         'Use-PythonInstallRequirementsToVENV',
                         'ConvertFrom-HashtableToPSObject',
                         'Get-InstalledNodeNPMVersions'

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

