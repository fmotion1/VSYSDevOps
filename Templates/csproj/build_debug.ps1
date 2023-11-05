dotnet build .\{ProjectName}.csproj --configuration Debug
Write-Host -NoNewLine 'Compile complete. Press any key to exit.'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')