function New-DotnetAssemblyTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $ProjectName,

        [Parameter(Mandatory)]
        [String]
        $OutputPath,

        [Parameter(Mandatory=$false)]
        [ValidateSet('net6.0', 'net7.0', IgnoreCase = $true)]
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
        [ValidateSet('true', 'false', IgnoreCase = $true)]
        [String]
        $AllowUnsafeBlocks = 'true'
    )

    process {

        If (!(Test-Path -LiteralPath $OutputPath -PathType Container)) {
            New-Item -Path $OutputPath -ItemType Directory -Force
        }
        
        $ProjectName = $ProjectName -replace '\s', ''
    
        $CSC = Get-Content "$PSScriptRoot\..\Templates\csproj\Class.cs" -Raw 
        $CSP = Get-Content "$PSScriptRoot\..\Templates\csproj\Class.csproj" -Raw 
        $DBG = Get-Content "$PSScriptRoot\..\Templates\csproj\build_debug.ps1" -Raw 
        $RLS = Get-Content "$PSScriptRoot\..\Templates\csproj\build_release.ps1" -Raw 

        $CSC = $CSC -replace '{ProjectName}', $ProjectName
        $CSC = $CSC -replace '{Namespace}', $Namespace
        $CSC | Set-Content -LiteralPath (Join-Path $OutputPath -ChildPath "$ProjectName.cs")

        $CSP = $CSP -replace '{TargetFramework}', $TargetFramework
        $CSP = $CSP -replace '{AllowUnsafeBlocks}', $AllowUnsafeBlocks
        $CSP = $CSP -replace '{Nullable}', $Nullable
        $CSP | Set-Content -LiteralPath (Join-Path $OutputPath -ChildPath "$ProjectName.csproj")

        $DBG = $DBG -replace '{ProjectName}', $ProjectName
        $DBG | Set-Content -LiteralPath (Join-Path $OutputPath -ChildPath "build_debug.ps1")

        $RLS = $RLS -replace '{ProjectName}', $ProjectName
        $RLS | Set-Content -LiteralPath (Join-Path $OutputPath -ChildPath "build_release.ps1")

    }
}