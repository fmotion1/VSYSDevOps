$Public = Get-ChildItem $PSScriptRoot\Public -Recurse -Include '*.ps1' -ea SilentlyContinue
$Private = Get-ChildItem $PSScriptRoot\Private -Recurse -Include '*.ps1' -ea SilentlyContinue

foreach ($Import in @($Public + $Private)) {
    try { . $Import.FullName } catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}

if (-not $script:DevOpsConfigFile) {
    $script:DevOpsConfigFile = Join-Path $PSScriptRoot -ChildPath 'Config.psd1'
}
if (-not $script:DevOpsConfigData){
    $DevOpsConfigHash = Import-PowerShellDataFile -Path $script:DevOpsConfigFile
    $script:DevOpsConfigData = ConvertFrom-HashtableToPSObject -HashTable $DevOpsConfigHash
}
if (-not $script:DevOpsConfigKeys){
    $script:DevOpsConfigKeys = $script:DevOpsConfigData.PSObject.Properties.Name
}
if (-not $script:DevOpsUserConfigFile){
    $script:DevOpsUserConfigFile = Join-Path $PSScriptRoot -ChildPath 'userconfig.json'
}
if (-not $script:DevOpsUserConfigData){
    $script:DevOpsUserConfigData = Get-Content -Path $script:DevOpsUserConfigFile -Raw | ConvertFrom-Json
}
if (-not $script:DevOpsUserConfigKeys) {
    $script:DevOpsUserConfigKeys = $script:DevOpsUserConfigData.PSObject.Properties.Name
}
if (-not $script:TemplatesPath){
    $TemplatesPath = $script:DevOpsConfigData.TemplatesRootPath
    $script:TemplatesPath = Resolve-Path -Path (Join-Path $PSScriptRoot -ChildPath $TemplatesPath)
}
# if (-not $script:BoilerplatesTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:DockerFileTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:DockerIgnoreTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:EditorConfigTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:ESLintRCTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:GithubTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:GitignoreTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:JSConfigTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:NPMIgnoreTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:NPMrcTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:OmnisharpJSONTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:PrettierIgnoreTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:PrettierRCTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:BoilerplatesTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:PythonVENVInstallTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:PythonVENVTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:SVGOConfigTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }
# if (-not $script:TSConfigJSONTemplatesPath){
#     $script:BoilerplatesTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'boilerplates'
# }

if (-not $script:LicenseTemplatesPath){
    $script:LicenseTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'license'
}
if (-not $script:LicenseTemplatesObject){
    $LicenseMetadataFile = Join-Path $script:LicenseTemplatesPath -ChildPath 'metadata.json'
    $LicenseMetadataJSON = Get-Content -Path $LicenseMetadataFile -Raw
    $script:LicenseTemplatesObject = $LicenseMetadataJSON | ConvertFrom-Json
}

if (-not $script:LicenseTemplatesData) {

    $LicenseTemplatesObj = $script:LicenseTemplatesObject
    $LicenseTemplatesArr = @()

    foreach ($obj in $LicenseTemplatesObj) {

        $CurrentObj = [PSCustomObject][Ordered]@{
            LicenseName          =  $obj.name
            LicenseFolder        =  $script:LicenseTemplatesPath
            LicensePath          =  (Join-Path $script:LicenseTemplatesPath -ChildPath $obj.path)
            LicenseVariables     =  @()
            LicenseVariableCount =  0
        }

        foreach ($variable in $obj.variables){
            $VariableObject = [PSCustomObject]@{
                VariableName        =  $variable.name
                VariablePattern     =  $variable.variable
                VariableUserConfig  =  $variable.userConfig
                VariableDescription =  $variable.description
            }
            $CurrentObj.LicenseVariables += $VariableObject
            $CurrentObj.LicenseVariableCount += 1
        }

        $LicenseTemplatesArr += $CurrentObj
    }

    $script:LicenseTemplateData = $LicenseTemplatesArr
}

Register-ArgumentCompleter -CommandName Get-DevOpsUserConfigSetting -ParameterName Key -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $script:DevOpsUserconfigKeys | Where-Object { $_ -like "$wordToComplete*" }
}

Register-ArgumentCompleter -CommandName Get-DevOpsConfigSetting -ParameterName Key -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $script:DevOpsConfigKeys | Where-Object { $_ -like "$wordToComplete*" }
}


function DevOpsDebug-PrintGlobalConfigData {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification='Debug Function')]
    param()
    Write-SpectreRule -Title "DevOps Global Config Data" -Alignment Center -Color "#FFFFFF"
    Write-Host ""

    Write-SpectreHost "    [#595C60]Global Config File (DevOpsConfigFile):[/] [#FFFFFF]$script:DevOpsConfigFile[/]"
    Write-SpectreHost "    [#595C60]Global Config Data (DevOpsConfigData):[/] [#FFFFFF]$script:DevOpsConfigData[/]"
    Write-SpectreHost "    [#595C60]Global Config Keys (DevOpsConfigKeys):[/] [#FFFFFF]$script:DevOpsConfigKeys[/]"
    Write-Host ""
}

function DevOpsDebug-PrintUserConfigData {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification='Debug Function')]
    param()
    Write-SpectreRule -Title "DevOps User Config Data" -Alignment Center -Color "#FFFFFF"
    Write-Host ""

    Write-SpectreHost "    [#595C60]User Config File (DevOpsUserConfigFile):[/] [#FFFFFF]$script:DevOpsUserConfigFile[/]"
    Write-SpectreHost "    [#595C60]User Config Data (DevOpsUserConfigData):[/] [#FFFFFF]$script:DevOpsUserConfigData[/]"
    Write-SpectreHost "    [#595C60]User Config Keys (DevOpsUserConfigKeys):[/] [#FFFFFF]$script:DevOpsUserConfigKeys[/]"
    Write-Host ""
}

function DevOpsDebug-PrintTemplatesData {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification='Debug Function')]
    param()
    Write-SpectreRule -Title "DevOps Global Templates Data" -Alignment Center -Color "#FFFFFF"
    Write-Host ""

    Write-SpectreHost "    [#595C60]DevOps Templates Path (TemplatesPath):[/] [#FFFFFF]$script:TemplatesPath[/]"
    Write-SpectreHost "    [#595C60]User Config Data (DevOpsUserConfigData):[/] [#FFFFFF]$script:DevOpsUserConfigData[/]"
    Write-SpectreHost "    [#595C60]User Config Keys (DevOpsUserConfigKeys):[/] [#FFFFFF]$script:DevOpsUserConfigKeys[/]"
    Write-Host ""
}

function DevOpsDebug-PrintLicenseTemplateData {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification='Debug Function')]
    param()
    Write-SpectreRule -Title "DevOps License Template Data" -Alignment Center -Color "#FFFFFF"
    Write-Host ""
    Write-SpectreHost "[#FFFFFF]Printing output of `$script:LicenseTemplateData[/]"
    Write-Host ""

    $idx = 0
    foreach ($LicenseTemplate in $script:LicenseTemplateData) {
        if($idx -eq 0){
            $idx = 1
        } else{
            Write-Host ""
        }
        Write-Host -f Magenta $LicenseTemplate.LicenseName
        Write-Host ""
        Write-SpectreHost "    Folder: [#595C60]$($LicenseTemplate.LicenseFolder)[/]"
        Write-SpectreHost "    Full Path: [#595C60]$($LicenseTemplate.LicensePath)[/]"
        Write-SpectreHost "    Variable Count: [#595C60]$($LicenseTemplate.LicenseVariableCount)[/]"
        Write-Host ""

        if($LicenseTemplate.LicenseVariableCount -gt 0){

            Write-SpectreHost "[#FFFFFF]    $($LicenseTemplate.LicenseName) Variables:[/]"

            foreach ($LicenseVariableObj in $LicenseTemplate.LicenseVariables) {
                Write-Host ""
                Write-SpectreHost "    VariableName: [#595C60]$($LicenseVariableObj.VariableName)[/]"
                Write-SpectreHost "    VariablePattern: [#595C60]$($LicenseVariableObj.VariablePattern)[/]"
                Write-SpectreHost "    VariableUserConfig: [#595C60]$($LicenseVariableObj.VariableUserConfig)[/]"
                Write-SpectreHost "    VariableDescription: [#595C60]$($LicenseVariableObj.VariableDescription)[/]"
            }
        }else{
            Write-SpectreHost "[#abafb3]    No variables are defined for this template [#FFFFFF]($($LicenseTemplate.LicenseName))[/].[/]"
            Write-Host ""
        }
    }
}


if($script:DevOpsConfigData.Configuration -eq 'Debug'){
    Write-SpectreHost "[#f58b95]DevOps Debug configuration is set.[/]"
    Write-Host ""
    DevOpsDebug-PrintLicenseTemplateData

}

# Register-ArgumentCompleter -CommandName Get-LicenseTemplate -ParameterName Template -ScriptBlock {
#     param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
#     if (-not $script:DevOpsLicenseTemplateNames) {

#     }

#     $script:DevOpsConfigValues | Where-Object { $_ -like "$wordToComplete*" }
# }