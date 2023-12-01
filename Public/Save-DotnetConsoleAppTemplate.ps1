function Save-DotnetConsoleAppTemplate {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [String]
        $OutputPath,

        [Parameter(Mandatory)]
        [String]
        $ProjectName,

        [Parameter(Mandatory=$false)]
        [ValidateSet('exe', 'library', IgnoreCase = $true)]
        [String]
        $OutputTypeRelease = 'exe',

        [Parameter(Mandatory=$false)]
        [ValidateSet('exe', 'library', IgnoreCase = $true)]
        [String]
        $OutputTypeDebug = 'library',

        [Parameter(Mandatory=$false)]
        [ValidateSet('x64', 'x86')]
        [String]
        $PlatformArch = 'x64',

        [Parameter(Mandatory=$false)]
        [ValidateSet('net6.0', 'net7.0', 'net8.0', IgnoreCase = $true)]
        [String]
        $TargetFramework = 'net6.0',

        [Parameter(Mandatory=$false)]
        [String]
        $Namespace = "DefaultNamespace",

        [Parameter(Mandatory=$false)]
        [ValidateSet('enable', 'disable', IgnoreCase = $true)]
        [String]
        $Nullable = 'enable',

        [Parameter(Mandatory=$false)]
        [ValidateSet('enable', 'disable', IgnoreCase = $true)]
        [String]
        $ImplicitUsings = 'enable',

        [Parameter(Mandatory=$false)]
        [ValidateSet('true', 'false', IgnoreCase = $true)]
        [String]
        $AllowUnsafeBlocks = 'false'
    )

    process {

        If (!(Test-Path -LiteralPath $OutputPath -PathType Container)) {
            New-Item -Path $OutputPath -ItemType Directory -Force
        } else {
            if((Get-ChildItem -LiteralPath $OutputPath).Length -ne 0){
                Write-Error "The target path ($OutputPath) isn't empty. Please specify an empty or non-existant directory."
            }
        }

        $ProjectName = $ProjectName -replace '\s', ''

        $CSC = Get-Content "$PSScriptRoot\..\Templates\CSharp\ConsoleApp\Program.cs" -Raw
        $CSP = Get-Content "$PSScriptRoot\..\Templates\CSharp\ConsoleApp\class.csproj" -Raw
        $DBG = Get-Content "$PSScriptRoot\..\Templates\CSharp\ConsoleApp\build_debug.ps1" -Raw
        $RLS = Get-Content "$PSScriptRoot\..\Templates\CSharp\ConsoleApp\build_release.ps1" -Raw

        $CSC = $CSC -replace '{ProjectName}', $ProjectName
        $CSC = $CSC -replace '{Namespace}', $Namespace
        $CSC | Set-Content -LiteralPath (Join-Path $OutputPath -ChildPath "$ProjectName.cs")

        $CSP = $CSP -replace '{TargetFramework}', $TargetFramework
        $CSP = $CSP -replace '{AllowUnsafeBlocks}', $AllowUnsafeBlocks
        $CSP = $CSP -replace '{Nullable}', $Nullable
        $CSP = $CSP -replace '{ImplicitUsings}', $ImplicitUsings
        $CSP = $CSP -replace '{PlatformArch}', $PlatformArch
        $CSP | Set-Content -LiteralPath (Join-Path $OutputPath -ChildPath "$ProjectName.csproj")

        $DBG = $DBG -replace '{ProjectName}', $ProjectName
        $DBG | Set-Content -LiteralPath (Join-Path $OutputPath -ChildPath "build_debug.ps1")

        $RLS = $RLS -replace '{ProjectName}', $ProjectName
        $RLS | Set-Content -LiteralPath (Join-Path $OutputPath -ChildPath "build_release.ps1")

    }
}