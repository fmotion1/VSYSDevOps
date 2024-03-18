Push-Location $PSScriptRoot -StackName DotnetBuild
dotnet build .\{ProjectName}.csproj --configuration Release
Pop-Location -StackName DotnetBuild
Read-Host "Press any key to exit."

