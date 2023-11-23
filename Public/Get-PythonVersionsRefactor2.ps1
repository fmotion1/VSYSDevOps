function Get-PythonVersionsRefactor2 {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(Mandatory=$false, HelpMessage="Display only Paths")]
        [Parameter(Mandatory, ParameterSetName='PathOnly', HelpMessage="Display only paths")]
        [switch]
        $PathOnly,

        [Parameter(Mandatory=$false, HelpMessage="Display only Versions")]
        [Parameter(Mandatory, ParameterSetName='VersionOnly', HelpMessage="Display only versions")]
        [switch]
        $VersionOnly,

        [Parameter(Mandatory=$false, HelpMessage="Display only Versions")]
        [Parameter(Mandatory, ParameterSetName='VersionAndPath', HelpMessage="Display only versions and paths")]
        [switch]
        $VersionAndPath,

        [Parameter(Mandatory=$false, HelpMessage="Filter results by major release (2 or 3)")]
        [ValidateSet('CURRENT','OLD','ALL','2','3', IgnoreCase = $true)]
        [String]
        $Branch = 'ALL',

        [Parameter(Mandatory=$false, HelpMessage="Add a leading 'v' to the version strings")]
        [switch]
        $InsertLeadingV,

        [Parameter(Mandatory=$false, ParameterSetName='VersionOnly', HelpMessage="Add branch labels to results")]
        [Parameter(Mandatory=$false, ParameterSetName='VersionAndPath', HelpMessage="Add branch labels to results")]
        [Parameter(Mandatory=$false, ParameterSetName='PathOnly', HelpMessage="Add branch labels to results")]
        [switch]
        $ShowBranch,

        [Parameter(Mandatory=$false)]
        [Switch]
        $ShowTable
    )

    # Check if PY Launcher is available on the system PATH
    try {
        $PYCMD = Get-Command py -CommandType Application
    } catch {
        $ErrorText = "The Python PY Launcher isn't available in your PATH environment variable."
        $eRecord = [System.Management.Automation.ErrorRecord]::new(
            [System.Management.Automation.CommandNotFoundException]::new($ErrorText),
            'CommandNotFound',
            'CommandNotFound',
            $PYCMD
        )
        $PSCmdlet.ThrowTerminatingError($eRecord)
    }

    # Parsing Start

    $GetPathsAndVersions = {

        param (
            [Parameter(Mandatory)] $Python0,
            [Parameter(Mandatory)] $Python0p,
            [Switch] $InsertV,
            [Switch] $IncludeBranch,
            [String] $FilterBranch,
            [Switch] $ShowVersion,
            [Switch] $ShowPath
        )


        $Python0 | ForEach-Object {
            if([String]::IsNullOrEmpty($_)){ return }
        }

        $Python0p | ForEach-Object {
            if([String]::IsNullOrEmpty($_)){ return }
        }

        $VersionArr = [System.Collections.Generic.List[String]]@()
        $ArchArr    = [System.Collections.Generic.List[String]]@()
        $PathArr    = [System.Collections.Generic.List[String]]@()
        $BranchArr  = [System.Collections.Generic.List[String]]@()

        $Py0Output = $PY1Results -split "\r?\n"
        $Py0pOutput = $PY2Results -split "\r?\n"

        for ($i = 0; $i -lt $Py0Output.Length; $i++) {
            if ($Py0Output[$i] -match '-V:(\d+\.\d+)\s*\*?\s+Python\s+\d+\.\d+\s*(\(\d+-bit\))?') {
                $VersionArr += $matches[1]
                $ArchArr += if ($matches[2]) { $matches[2] } else { "NONE" }
                
                if(($VersionArr -like '2.*')){
                    $BranchArr += 'OLD'
                }else{
                    $BranchArr += 'CURRENT'
                }
            }
        }

        for ($j = 0; $j -lt $Py0pOutput.Length; $j++) {
            $Py0pOutput[$j] -match '[A-Z]:\\.*$'
            $PathArr += $matches[0]
        }

        
        if($IncludeBranch) {
            for ($k = 0; $k -lt $PathArr.Count; $k++) {
                [PSCustomObject]@{
                    Version = $VersionArr[$k]
                    Branch = $BranchArr[$k]
                    Architecture = $ArchArr[$k]
                    Path = $PathArr[$k]
                }
            }
        } else {
            for ($k = 0; $k -lt $PathArr.Count; $k++) {
                [PSCustomObject]@{
                    Version = $VersionArr[$k]
                    Architecture = $ArchArr[$k]
                    Path = $PathArr[$k]
                }
            }
        }
    }


    $PY1Results = & $PYCMD -0
    $PY2Results = & $PYCMD -0p

    if((!$VersionAndPath) -and (!$VersionOnly) -and (!$PathOnly)){
        $outputSplat = @{
            Python0        = $PY1Results
            Python0p       = $PY2Results
            InsertV        = $InsertLeadingV
            ShowBranch     = $true
            FilterBranch   = $Branch
        }
        $Output = & $GetRequestedDataset @outputSplat
    }
    elseif($VersionAndPath){
        $outputSplat = @{
            Python0        = $PY1Results
            Python0p       = $PY2Results
            InsertV        = $InsertLeadingV
            ShowBranch     = $ShowBranch
            FilterBranch   = $Branch
        }
        $Output = & $GetRequestedDataset @outputSplat
    }
    
}

#Get-PythonVersions