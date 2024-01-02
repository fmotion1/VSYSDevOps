dotnet build .\WindowsVersion.csproj --configuration Release
Write-Host -NoNewLine 'Press any key to continue with the operation.'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')