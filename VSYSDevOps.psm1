$Public = Get-ChildItem $PSScriptRoot\Public -Recurse -Include '*.ps1' -ea SilentlyContinue
$Private = Get-ChildItem $PSScriptRoot\Private -Recurse -Include '*.ps1' -ea SilentlyContinue

foreach ($Import in @($Public + $Private)) {
    try { . $Import.FullName } catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}

Register-ArgumentCompleter -CommandName Get-DevOpsUserConfigSetting -ParameterName Key -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    if (-not $script:DevOpsUserconfigKeys) {
        $UserConfigFile = Join-Path $PSScriptRoot -ChildPath 'userconfig.json'
        $UserConfigObject = Get-Content -Path $UserConfigFile -Raw | ConvertFrom-Json
        $UserConfigKeys = $UserConfigObject.PSObject.Properties.Name
        $script:DevOpsUserconfigKeys = $UserConfigKeys
    }

    $script:DevOpsUserconfigKeys | Where-Object { $_ -like "$wordToComplete*" }
}


Register-ArgumentCompleter -CommandName Get-DevOpsConfigSetting -ParameterName Key -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    if (-not $script:DevOpsConfigValues) {
        $ModuleConfigFile = Join-Path $PSScriptRoot -ChildPath 'Config.psd1'
        [hashtable] $ModuleConfigData = Import-PowerShellDataFile -Path $ModuleConfigFile
        [array] $ConfigKeys = @()
        foreach ($K in $ModuleConfigData) {
            $ConfigKeys += $K.Keys
        }
        $script:DevOpsConfigValues = $ConfigKeys
    }

    $script:DevOpsConfigValues | Where-Object { $_ -like "$wordToComplete*" }
}