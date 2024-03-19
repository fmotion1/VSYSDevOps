$Public = Get-ChildItem $PSScriptRoot\Public -Recurse -Include '*.ps1' -ea SilentlyContinue
$Private = Get-ChildItem $PSScriptRoot\Private -Recurse -Include '*.ps1' -ea SilentlyContinue

foreach ($Import in @($Public + $Private)) {
    try { . $Import.FullName } catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}

# GOOGLE TRANSLATE DATA  ############################################################
#####################################################################################

# $script:LanguagesCsv = ConvertFrom-Csv -InputObject (Get-Content "$PSScriptRoot/Languages.csv" -Raw)

# $LanguageToCode = @{}
# $CodeToLanguage = @{}

# foreach ($row in $script:LanguagesCsv)
# {
#     $LanguageToCode[$row.Language] = $row.Code
#     $CodeToLanguage[$row.Code] = $row.Language
# }

# $script:PairOfSourceLanguageAndCode = $script:LanguagesCsv | ForEach-Object { $_.Language, $_.Code }
# $script:PairOfTargetLanguageAndCode = $script:LanguagesCsv | Where-Object { $_.Code -ine 'auto' } | ForEach-Object { $_.Language, $_.Code }


if (-not $script:DevOpsConfigFile) {
    $script:DevOpsConfigFile = Join-Path $PSScriptRoot -ChildPath 'config.json'
}

if (-not $script:DevOpsConfigData){
    $script:DevOpsConfigData = Get-Content -Path $script:DevOpsConfigFile -Raw | ConvertFrom-Json
}

if (-not $script:DevOpsConfigKeys){
    $script:DevOpsConfigKeys = $script:DevOpsConfigData.PSObject.Properties.Name
}

if (-not $script:DevOpsUserConfigFile) {
    $script:DevOpsUserConfigFile = Join-Path $PSScriptRoot -ChildPath 'userconfig.json'
}

if (-not $script:DevOpsUserConfigData){
    $script:DevOpsUserConfigData = Get-Content -Path $script:DevOpsUserConfigFile -Raw | ConvertFrom-Json
}
if (-not $script:DevOpsUserConfigKeys) {
    $script:DevOpsUserConfigKeys = $script:DevOpsUserConfigData.PSObject.Properties.Name
}

# MODULE IMPORTANT PATHS AND FILES  #################################################
#####################################################################################

if (-not $script:TemplatesPath){
    $TemplatesFolder = ($script:DevOpsConfigData)."System.TemplatesRoot"
    $script:TemplatesPath = Resolve-Path -Path (Join-Path $PSScriptRoot -ChildPath $TemplatesFolder)
}

if (-not $script:TemplatesDataObject){
    $script:TemplatesDataObject = ($script:DevOpsConfigData)."System.Templates"
}

if (-not $script:ModuleAssembliesPath){
    $AssembliesFolder = ($script:DevOpsConfigData)."System.AssembliesRoot"
    $script:ModuleAssembliesPath = Resolve-Path -Path (Join-Path $PSScriptRoot -ChildPath $AssembliesFolder)
}

if (-not $script:PythonVenvPath){
    $PythonVenvFolder = ($script:DevOpsConfigData)."System.PythonVenvRoot"
    $script:PythonVenvPath = Resolve-Path -Path (Join-Path $PSScriptRoot -ChildPath $PythonVenvFolder)
}

if (-not $script:PythonScriptsPath){
    $PythonScriptsFolder = ($script:DevOpsConfigData)."System.PythonScriptsRoot"
    $script:PythonScriptsPath = Resolve-Path -Path (Join-Path $PSScriptRoot -ChildPath $PythonScriptsFolder)
}


# LICENSE TEMPLATE VARIABLES  #######################################################

if (-not $script:LicenseTemplatesPath){
    $script:LicenseTemplatesPath = Join-Path -Path $script:TemplatesPath -ChildPath 'license'
}

if (-not $script:LicenseTemplatesObject){
    $LicenseMetadataFile = Join-Path $script:LicenseTemplatesPath -ChildPath 'metadata.json'
    $LicenseMetadataJSON = Get-Content -Path $LicenseMetadataFile -Raw
    $script:LicenseTemplatesObject = $LicenseMetadataJSON | ConvertFrom-Json
}

if(-not $script:LicenseTemplateKeys){
    $LicenseTemplatesObj = $script:LicenseTemplatesObject
    $LicenseTemplatesKeyArr = @()

    foreach ($obj in $LicenseTemplatesObj) {
        $LicenseTemplatesKeyArr += $obj.name
    }
    $script:LicenseTemplateKeys = $LicenseTemplatesKeyArr
}

Register-ArgumentCompleter -CommandName Get-DevOpsUserConfigSetting -ParameterName Key -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $script:DevOpsUserconfigKeys | Where-Object { $_ -like "$wordToComplete*" }
}

Register-ArgumentCompleter -CommandName Get-DevOpsConfigSetting -ParameterName Key -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $script:DevOpsConfigKeys | Where-Object { $_ -like "$wordToComplete*" }
}

Register-ArgumentCompleter -CommandName Get-LicenseTemplate -ParameterName Template -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $script:LicenseTemplateKeys | Where-Object { $_ -like "$wordToComplete*" }
}


# Register-ArgumentCompleter -CommandName Get-LicenseTemplate -ParameterName Template -ScriptBlock {
#     param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
#     if (-not $script:DevOpsLicenseTemplateNames) {

#     }

#     $script:DevOpsConfigValues | Where-Object { $_ -like "$wordToComplete*" }
# }