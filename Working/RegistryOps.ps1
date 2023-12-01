function Add-RegistryPSDrive {

    # Added by default:
    # HKCU HKEY_CURRENT_USER  Microsoft.PowerShell.Core\Registry
    # HKLM HKEY_LOCAL_MACHINE Microsoft.PowerShell.Core\Registry

    # Needs to be mounted manually:
    # HKCR HKEY_CLASSES_ROOT
    # HKU  HKEY_USERS
    # HKCC HKEY_CURRENT_CONFIG

    param (
        [Parameter(Mandatory, ParameterSetName="Individual", Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('HKCR','HKCC','HKU')]
        [String[]]$DrivePrefix,

        [Parameter(Mandatory, ParameterSetName="All", Position=0)]
        [Switch]$All,

        [Switch]$HideConfirmation
        
    )

    $DriveTable = @{
        HKCR = "HKEY_CLASSES_ROOT"
        HKCC = "HKEY_CURRENT_CONFIG"
        HKU  = "HKEY_USERS"
    }

    if(!$All){
        foreach ($Prefix in $DrivePrefix) {
            $Drive = $DriveTable.Item($Prefix)
            if(!(Test-Path "$Prefix`:")){
                New-PSDrive -PSProvider Registry -Root $Drive -Name $Prefix -Scope Global
            } else {
                if(!$HideConfirmation) { Write-Host "$Drive ($Prefix) has already been mounted." }
            }
        }
    }else{

        if(!(Test-Path "HKCR:")){

            $newPSDriveSplat = @{
                PSProvider = 'Registry'
                Root = 'HKEY_CLASSES_ROOT'
                Name = 'HKCR'
                Scope = 'Global'
            }
            New-PSDrive @newPSDriveSplat | Select-Object -Property Name, Provider, Root
        }
        if(!(Test-Path "HKCC:")){

            $newPSDriveSplat = @{
                PSProvider = 'Registry'
                Root = 'HKEY_CURRENT_CONFIG'
                Name = 'HKCC'
                Scope = 'Global'
            }

            New-PSDrive @newPSDriveSplat | Select-Object -Property Name, Provider, Root
        }
        if(!(Test-Path "HKU:")){

            $newPSDriveSplat = @{
                PSProvider = 'Registry'
                Root = 'HKEY_USERS'
                Name = 'HKU'
                Scope = 'Global'
            }

            New-PSDrive @newPSDriveSplat | Select-Object -Property Name, Provider, Root
        }
    }
}



function Resolve-ToValidRegistryPath {
    [CmdletBinding()]
    param (
        [Parameter( Position=0,
                    Mandatory, 
                    ValueFromPipeline, 
                    ValueFromPipelineByPropertyName
                    )]
        [ValidateNotNullOrEmpty()]           
        [Alias("PSPath")]            
        [String[]]$Path
        
    )
    process {
        foreach ($P in $Path) {
            $P = $P.Replace('HKEY_CLASSES_ROOT\\',   'HKCR:\\')
            $P = $P.Replace('HKEY_CURRENT_USER\\',   'HKCU:\\')
            $P = $P.Replace('HKEY_LOCAL_MACHINE\\',  'HKLM:\\')
            $P = $P.Replace('HKEY_USERS\\',          'HKU:\\')
            $P = $P.Replace('HKEY_CURRENT_CONFIG\\', 'HKCC:\\')
            $P
        }
    }
}

function Test-RegistryPathExists {
    [CmdletBinding()]
    param (
        [Parameter( Position=0,
                    Mandatory, 
                    ValueFromPipeline, 
                    ValueFromPipelineByPropertyName
                    )]
        [ValidateNotNullOrEmpty()]           
        [Alias("PSPath")]            
        [String[]]$Path
    )
    process{

        foreach ($P in $Path) {

            if($P.ToUpper().Contains('HKEY_CLASSES_ROOT\\')){
                $P = Resolve-ToValidRegistryPath -Path $P
            }
            elseif($P.ToUpper().Contains('HKEY_CURRENT_USER\\')){
                $P = Resolve-ToValidRegistryPath -Path $P
            }
            elseif($P.ToUpper().Contains('HKEY_LOCAL_MACHINE\\')){
                $P = Resolve-ToValidRegistryPath -Path $P
            }
            elseif($P.ToUpper().Contains('HKEY_USERS\\')){
                $P = Resolve-ToValidRegistryPath -Path $P
            }
            elseif($P.ToUpper().Contains('HKEY_CURRENT_CONFIG\\')){
                $P = Resolve-ToValidRegistryPath -Path $P
            }

            if(Test-Path $P){
                [PSCustomObject]@{
                    Path = $P
                    Exists = $true
                }
                #$true
            } else {
                [PSCustomObject]@{
                    Path = $P
                    Exists = $false
                }
                #$false
            }
        }
    }
}


Function Test-RegistryValueExists {
    [CmdletBinding()]
    param(
        [Parameter( Position=0,
                    Mandatory, 
                    ValueFromPipeline, 
                    ValueFromPipelineByPropertyName
                    )]
        [ValidateNotNullOrEmpty()]           
        [Alias("PSPath")]            
        [String]$Path,

        [String]$Value,
        [Switch]$PassThru
    ) 

    process {
        if([String]::IsNullOrEmpty($Value)){
            (Test-Path $Path) ? $true : $false
        }else{
            $Ref = Get-Item -LiteralPath $Path
            if ($null -ne $Ref.GetValue($Value, $null)) {
                if ($PassThru) {Get-ItemProperty $Path $Value}
                else {$true}
            }else{
                $false
            }
        }
    }
}

function Show-AllRegistryDrives {
    $data = Get-PSDrive -PSProvider Registry | Select-Object Name, Root, Provider
    Format-SpectreTable -Data $data -Border Square -Color Grey35
}


Add-RegistryPSDrive -All | Out-Null

$p1 = "HKEY_CLASSES_ROOT\\Directory\Background\shell\c10_SwitchNodeVersion"
$p2 = "HKCR:\\Directory\Background\shell\c14_CreateNodeWorkspace"

$p1 | Resolve-ToValidRegistryPath | Test-RegistryPathExists
$p2 | Test-RegistryPathExists