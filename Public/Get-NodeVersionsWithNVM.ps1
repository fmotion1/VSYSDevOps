function Get-NodeVersionsWithNVM {
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

        [Parameter(Mandatory=$false, HelpMessage="Add a leading 'v' to the version strings.")]
        [switch]
        $InsertLeadingV,

        [Parameter(Mandatory=$false, ParameterSetName='VersionOnly', HelpMessage="Add branch labels to results")]
        [Parameter(Mandatory=$false, ParameterSetName='VersionAndPath', HelpMessage="Add branch labels to results")]
        [switch]
        $ShowBranch
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

    ## Check if NVM is available on the system PATH
    try {
        $NVMCMD = Get-Command nvm.exe
    } catch {
        $ErrorText = "NVM Node Version Manager isn't installed or available in your PATH environment variable."
        $eRecord = [System.Management.Automation.ErrorRecord]::new(
            [System.Management.Automation.CommandNotFoundException]::new($ErrorText),
            'CommandNotFound',
            'CommandNotFound',
            $NVMCMD
        )
        $PSCmdlet.ThrowTerminatingError($eRecord)
    }

    # Version Branch Parser
    $GetBranch = {
        param (
            [Parameter(Mandatory)] $Version
        )
        $Version = $Version.TrimStart('v')
        if($Version -match '^0\.([\d\.]+)') {
            'OLD'
            return
        }
        'CURRENT'
    }

    # Version Parser
    $GetVersions = {
        param (
            [Parameter(Mandatory)] $NVMListInput,
            [Switch] $InsertV,
            [Switch] $IncludeBranch,
            [String] $FilterBranch
        )

        $NVMListInput = $NVMListInput -split "\r?\n"

        for ($idx = 0; $idx -lt $NVMListInput.Count; $idx++) {
            if([String]::IsNullOrEmpty($NVMListInput[$idx])){
                continue
            }

            $nodeVersion = $NVMListInput[$idx] -replace '\* ', ''
            $nodeVersion = $nodeVersion -replace '\(([\w\s\-]+)\)', ''
            $nodeVersion = $nodeVersion.Trim()
            if($InsertV){$nodeVersion = "v$nodeVersion"}
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
            [Switch] $InsertV,
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
        $nodeDirs | ForEach-Object {
            $nodeVersion = (!$InsertV) ? $($_.Name.TrimStart('v')) : $($_.Name)
            $nodePath = $_.FullName
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
    $NODE1 = & $NVMCMD list
    $NODE2 = & $NVMCMD root

    if((!$VersionAndPath) -and (!$VersionOnly)){
        $outputSplat = @{
            NVMRootInput   = $NODE2
            InsertV        = $InsertLeadingV
            IncludeBranch  = $true
            FilterBranch   = $Branch
        }
        $Output = & $GetPathsAndVersions @outputSplat
    }
    elseif($VersionOnly){
        $outputSplat = @{
            NVMListInput   = $NODE1
            InsertV        = $InsertLeadingV
            IncludeBranch  = $ShowBranch
            FilterBranch   = $Branch
        }
        $Output = & $GetVersions @outputSplat
    }
    elseif($VersionAndPath){
        $outputSplat = @{
            NVMListInput   = $NODE2
            InsertV        = $InsertLeadingV
            IncludeBranch  = $ShowBranch
            FilterBranch   = $Branch
        }
        $Output = & $GetPathsAndVersions @outputSplat
    }

    $Output
}