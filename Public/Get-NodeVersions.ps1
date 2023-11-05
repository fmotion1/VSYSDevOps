function Get-NodeVersions {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    
    param (

        [Parameter(Mandatory=$false, HelpMessage="Display only Paths")]
        [switch]
        $PathOnly,

        [Parameter(Mandatory=$false, HelpMessage="Display only Versions")]
        [switch]
        $VersionOnly,

        [Parameter(Mandatory=$false, HelpMessage="Omit the leading 'v' from Version Strings.")]
        [switch]
        $VersionOmitLeadingV,

        [Parameter(Mandatory=$false, ParameterSetName='All')]
        [Parameter(Mandatory, ParameterSetName='LatestOnly', HelpMessage="Return only the latest version of Node")]
        [Switch]
        $GetLatestOnly,

        [Parameter(Mandatory=$false, ParameterSetName='All')]
        [Parameter(Mandatory, ParameterSetName='OldestOnly', HelpMessage="Return only the oldest version of Node")]
        [Switch]
        $GetOldestOnly
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

    ## Check if NVM is available on the system in PATH
    try {
        $NVMCMD = Get-Command nvm.exe
    } catch {
    $ErrorText = "NVM Node Version Manager isn't installed or available in PATH environment variable."
    $eRecord = [System.Management.Automation.ErrorRecord]::new(
        [System.Management.Automation.CommandNotFoundException]::new($ErrorText),
        'CommandNotFound',
        'CommandNotFound',
        $NVMCMD
    )
    $PSCmdlet.ThrowTerminatingError($eRecord)
    }

    ##  Get the root installation path for NVM and normalize it to a
    ##  path. Then get all directories within that path as
    ##  [System.IO.DirectoryInfo] objects.
    $R = @(& nvm root)
    [String]$NVMRoot = $R[1]
    $NVMRoot = $NVMRoot -replace 'Current Root: '
    $VersionsSplat = @{
        LiteralPath = $NVMRoot
        Directory = $true
    }
    $NVMDirectoryInfoData = Get-ChildItem @VersionsSplat



    ##  Define Version and Path Lists for Aggregation
    $FinalAllVersionsList = [System.Collections.Generic.List[String]]@()
    $FinalAllPathsList = [System.Collections.Generic.List[String]]@()

    ## ALL: Display both version and Path
    if(($PSCmdlet.ParameterSetName -eq 'All') -and (!$VersionOnly) -and (!$PathOnly)){

        $NVMDirectoryInfoData | ForEach-Object {
            if($VersionOmitLeadingV){
                $FinalAllVersionsList.Add($_.Name.TrimStart('v'))
            }else {
                $FinalAllVersionsList.Add($_.Name)
            }
            $FinalAllPathsList.Add($_.FullName)
        }

        $FinalAllVersionsList = $FinalAllVersionsList | Sort-Object -Descending
        $FinalAllPathsList = $FinalAllPathsList | Sort-Object -Descending
        [System.Array]$FinalPSObjectArr = @()
        for ($i = 0; $i -lt $FinalAllVersionsList.Count; $i++) {
            $FinalPSObjectArr += [PSCustomObject][ordered]@{
                Version = $FinalAllVersionsList[$i]
                Path = $FinalAllPathsList[$i]
            }
        }

        if($GetLatestOnly){ $FinalPSObjectArr[0] }
        elseif($GetOldestOnly){ $FinalPSObjectArr[$FinalPSObjectArr.Count-1] }
        else{$FinalPSObjectArr}
    }

    ## VERSIONS: Display Versions Only
    $FinalVersionsList = [System.Collections.Generic.List[String]]@()
    if($VersionOnly){
        $NVMDirectoryInfoData | ForEach-Object {
            if($VersionOmitLeadingV){
                $FinalVersionsList.Add($_.Name.TrimStart('v'))
            }else {
                $FinalVersionsList.Add($_.Name)
            }
        }

        $FinalVersionsList = $FinalVersionsList | Sort-Object -Descending

        [System.Array]$FinalPSObjectArr = @()
        for ($i = 0; $i -lt $FinalVersionsList.Count; $i++) {
            $FinalPSObjectArr += $FinalVersionsList[$i]
        }

        if($GetLatestOnly){ $FinalPSObjectArr[0] }
        elseif($GetOldestOnly){ $FinalPSObjectArr[$FinalPSObjectArr.Count-1] }
        else{$FinalPSObjectArr}

    }

    ## PATHS: Display only Paths
    $FinalPathsList = [System.Collections.Generic.List[String]]@()
    if($PathOnly){
        $NVMDirectoryInfoData | ForEach-Object {
            $FinalPathsList.Add($_.FullName)
        }
        $FinalPathsList = $FinalPathsList | Sort-Object -Descending

        if($GetLatestOnly){ $FinalPathsList[0] }
        elseif($GetOldestOnly){ $FinalPathsList[$FinalPathsList.Count-1] }
        else{$FinalPathsList}
    }
}

