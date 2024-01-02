dotnet build .\WindowsVersion.csproj --configuration Debug
Write-Host -NoNewLine 'Press any key to continue with the operation.'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
