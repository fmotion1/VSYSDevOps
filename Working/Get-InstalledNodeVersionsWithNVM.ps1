using namespace System.Management.Automation

class NodeVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-InstalledNodeVersionsCompleter
        return $v
    }
}
function Get-InstalledNodeVersionsWithNVM {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(Mandatory=$false, HelpMessage="Display only versions")]
        [Parameter(Mandatory, ParameterSetName='VersionOnly', HelpMessage="Display only versions")]
        [switch]
        $VersionOnly,

        [Parameter(Mandatory=$false, HelpMessage="Display only version and path")]
        [Parameter(Mandatory, ParameterSetName='VersionAndPath', HelpMessage="Display only version and path")]
        [switch]
        $VersionAndPath,

        [Parameter(Mandatory=$false, HelpMessage="Filter by branch")]
        [ValidateSet('CURRENT','OLD','ALL', IgnoreCase = $true)]
        [String]
        $Branch = 'ALL',

        [Parameter(Mandatory=$false, ParameterSetName='VersionOnly', HelpMessage="Add branch labels to results")]
        [Parameter(Mandatory=$false, ParameterSetName='VersionAndPath', HelpMessage="Add branch labels to results")]
        [switch]
        $ShowBranch,

        [Parameter(HelpMessage="Return only specific versions.")]
        [ValidateSet([NodeVersions])]
        [string[]]
        $FilterVersions,

        [Parameter(Mandatory=$false)]
        [Switch]
        $Table
    )

    ## Parameter Validation
    if($PathOnly -and $VersionOnly){
        Write-Error "PathOnly and VersionOnly cannot be used together."
        return
    }
    if($GetLatestOnly -and $GetOldestOnly){
        Write-Error "GetLatestOnly and GetOldestOnly cannot be used together."
        return
    }

    #Write-Host "`$FilterVersions:" $FilterVersions -ForegroundColor Green
    #$FilterVersions = $FilterVersions | Sort-Object -Descending

    # Version Branch Parser
    $GetBranch = {
        param (
            [Parameter(Mandatory)] $Version
        )
        $VersionTemp = $Version -as [string]
        $VersionTemp = $VersionTemp.TrimStart('v')
        if($VersionTemp -match '^0\.([\d\.]+)') {
            'OLD'
            return
        }
        'CURRENT'
    }

    # Version Parser
    $GetVersions = {
        param (
            [Parameter(Mandatory)] $NVMListInput,
            [Switch] $IncludeBranch,
            [String] $FilterBranch
        )

        $NVMListInput = $NVMListInput -split "\r?\n"

        #:outer foreach ($NVMListItem in $NVMListInput -split '\r?\n') {
        foreach ($NVMListItem in $NVMListInput -split '\r?\n') {

            if([String]::IsNullOrEmpty($NVMListItem)){
                continue
            }

            $nodeVersion = $NVMListItem -replace '\* ', ''
            $nodeVersion = $nodeVersion -replace '\(([\w\s\-]+)\)', ''
            $nodeVersion = $nodeVersion.Trim()
            $nodeVersion = $nodeVersion

            $branch = & $GetBranch -Version $nodeVersion
            if(($FilterBranch -eq 'CURRENT') -and ($branch -eq 'OLD')){
                continue
            }
            elseif(($FilterBranch -eq 'OLD') -and ($branch -eq 'CURRENT')){
                continue
            }
            if($IncludeBranch){
                [PSCustomObject]@{
                    Version = $nodeVersion
                    Branch = $branch
                }
            } else {
                @($nodeVersion)
            }
        }
    }

    # Path and Version Parser
    $GetPathsAndVersions = {
        param (
            [Parameter(Mandatory)] $NVMRootInput,
            [Switch] $IncludeBranch,
            [String] $FilterBranch
        )

        $NVMRoot = $NVMRootInput | ForEach-Object {
            if([String]::IsNullOrEmpty($_)){ return }
            $_ -replace 'Current Root: '
        }

        $nvmFoldersSplat = @{
            LiteralPath = $NVMRoot
            Filter = 'v*'
            Directory = $true
        }

        $nodeDirs = Get-ChildItem @nvmFoldersSplat | Sort-Object -Descending
    
        foreach ($NodeDir in $NodeDirs) {

            $nodeVersion = $NodeDir.Name.TrimStart('v')
            $nodeVersion = $nodeVersion
            $nodePath = $NodeDir.FullName
            $nodeBranch = & $GetBranch -Version $nodeVersion

            if(($FilterBranch -eq 'CURRENT') -and ($nodeBranch -eq 'OLD')){
                return
            }
            elseif(($FilterBranch -eq 'OLD') -and ($nodeBranch -eq 'CURRENT')){
                return
            }
            
            if($IncludeBranch){
                [PSCustomObject]@{
                    Version = $nodeVersion
                    Branch = $nodeBranch
                    Path = $nodePath
                }
            }
            else {
                [PSCustomObject]@{
                    Version = $nodeVersion
                    Path = $nodePath
                }
            }
            
        }
    }

    # End Parsing and Begin Logic

    ## Check if NVM is available on the system PATH
    try {
        $NVMCMD = Get-Command nvm -CommandType Application
    } catch {
        $ErrorText = "NVM Node Version Manager isn't installed or available in your PATH environment variable."
        $eRecord = [System.Management.Automation.ErrorRecord]::new(
            [System.Management.Automation.CommandNotFoundException]::new($ErrorText),
            'CommandNotFound',
            'CommandNotFound',
            $NVMCMD
        )
        Write-Error $eRecord
        return 2
    }

    $NODE1 = & $NVMCMD list
    $NODE2 = & $NVMCMD root

    if((!$VersionAndPath) -and (!$VersionOnly)){
        
        $outputSplat = @{
            NVMRootInput   = $NODE2
            IncludeBranch  = $true
            FilterBranch   = $Branch
        }
    
        $Output = & $GetPathsAndVersions @outputSplat
    }
    elseif($VersionOnly){

        $outputSplat = @{
            NVMListInput     = $NODE1
            IncludeBranch    = $ShowBranch
            FilterBranch     = $Branch
        }

        $Output = & $GetVersions @outputSplat
    }
    elseif($VersionAndPath){
        
        $outputSplat = @{
            NVMRootInput   = $NODE2
            IncludeBranch  = $ShowBranch
            FilterBranch   = $Branch
        }

        $Output = & $GetPathsAndVersions @outputSplat
    }



    if($FilterVersions){
        $Output2 = @()
        if($VersionOnly){
            foreach($Version in $FilterVersions){
                $Output2 += $Output | Where-Object { $_ -eq $Version}
            }
            $Output = $Output2 | Sort-Object -Descending
        }else{
            foreach($V in $FilterVersions){
                $Output2 += $V
                $Output | Add-Member -Name 'NewProperty' -Type NoteProperty -Value $ActualValue
            }
        }
        
    }

    
    if($Table){

        [System.Array]$DataArr = @()
        foreach ($Property in $Output) {
            $O = [pscustomobject]@{}
            if($Property.Version){ 
                $O | Add-Member -Name 'Version' -Type NoteProperty -Value $Property.Version 
                $VersionIsProperty = $true
            }
            elseif($Property -is [string]){ 
                $O | Add-Member -Name 'Version' -Type NoteProperty -Value $Property 
                $VersionIsProperty = $false
            }
            if($Property.Branch){ $O | Add-Member -Name 'Branch' -Type NoteProperty -Value $Property.Branch }
            if($Property.Path){ $O | Add-Member -Name 'Path' -Type NoteProperty -Value $Property.Path }
            $DataArr += $O
        }

        if($VersionIsProperty){
            $DataArr = $DataArr | Sort-Object -Property Version -Descending
        }else{
            $DataArr = $DataArr | Sort-Object -Descending
        }

        Format-SpectreTable -Data $DataArr -Border Square -Color Grey27

    }else{

        $Output | Sort-Object -Property Version -Descending

    }


    # if($Table){
    #     if((!$VersionAndPath) -and (!$VersionOnly)){

    #     }
    #     if(!$VersionOnly){
    #         $DataArr = @()
    #         foreach ($Property in $Output) {
    #             $O = [pscustomobject]@{}
    #             if($Property.Version){ $O | Add-Member -Name 'Version' -Type NoteProperty -Value $Property.Version }
    #             if($Property.Branch){ $O | Add-Member -Name 'Branch' -Type NoteProperty -Value $Property.Branch }
    #             if($Property.Path){ $O | Add-Member -Name 'Path' -Type NoteProperty -Value $Property.Path }
    #             $DataArr += $O
    #         }
    #         Format-SpectreTable -Data $DataArr -Border Square -Color Grey27
    #     }else{
    #         $DataArr = @()
    #         foreach ($Version in $Output) {
    #             $O = [PSCustomObject]@{Version = $Version}
    #             $DataArr += $O
    #         }
    #         #$DataArr = $DataArr | Sort-Object -Descending
    #         Format-SpectreTable -Data $DataArr -Border Square -Color Grey27
    #     }
    # }
}


