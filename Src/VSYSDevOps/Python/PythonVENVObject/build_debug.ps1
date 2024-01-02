Push-Location $PSScriptRoot -StackName MSBuild
dotnet build .\PythonVENVObject.csproj --configuration Debug
Pop-Location -StackName MSBuild
Write-Host -NoNewLine 'Compile complete. Press any key to exit.'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
