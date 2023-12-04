Push-Location $PSScriptRoot -StackName DotnetBuild
dotnet build .\{ProjectName}.csproj --configuration Release
Pop-Location -StackName DotnetBuild

Write-Host -NoNewLine 'Press any key to continue with the operation.'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

