function Get-PythonVersions {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(Mandatory=$false, HelpMessage="Display only Paths")]
        [switch]
        $PathOnly,

        [Parameter(Mandatory=$false, HelpMessage="Display only Versions")]
        [switch]
        $VersionOnly,

        [Parameter(Mandatory=$false, HelpMessage="Filter results by major release version")]
        [ValidateSet('3','2','ALL', IgnoreCase = $true)]
        [String]
        $FilterVersion = 'ALL',

        [Parameter(Mandatory=$false, HelpMessage="Add a leading 'v' to the version strings")]
        [switch]
        $InsertLeadingV,

        [Parameter(Mandatory=$false, ParameterSetName='All')]
        [Parameter(Mandatory, ParameterSetName='LatestOnly', HelpMessage="Return only the latest version of Node")]
        [Switch]
        $GetLatestOnly,

        [Parameter(Mandatory=$false, ParameterSetName='All')]
        [Parameter(Mandatory, ParameterSetName='OldestOnly', HelpMessage="Return only the oldest version of Node")]
        [Switch]
        $GetOldestOnly,

        [Parameter(Mandatory=$false)]
        [Switch]
        $NoTable
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

    ## Check if PY Launcher is available on the system PATH
    try {
        $PYLauncherCMD = Get-Command py.exe
    } catch {
        $ErrorText = "Python Launcher (py.exe) isn't installed or available in PATH environment variable."
        $eRecord = [System.Management.Automation.ErrorRecord]::new(
            [System.Management.Automation.CommandNotFoundException]::new($ErrorText),
            'CommandNotFound',
            'CommandNotFound',
            $PYLauncherCMD
        )
        $PSCmdlet.ThrowTerminatingError($eRecord)
    }

    # Initialize Variables to store Python Launcher results

    $pythonObjects = [System.Collections.Generic.List[Object]]@()
    $PY1 = $(@(& $PYLauncherCMD -0)) -split "\r?\n"
    $PY2 = $(@(& $PYLauncherCMD -0p)) -split "\r?\n"

    # Parser for Python Launcher results
    for ($idx = 0; $idx -lt $PY1.Count; $idx++) {

        $pyVersion = ''; $pyLabel = '';
        $pyArch = ''; $pyPath = '';

        $line = $PY1[$idx] -replace '\* ', ''
        $parts = -split $line
        $archPat = '\((\d+)-bit\)'
        $archMatch = [System.Text.RegularExpressions.Regex]::Match($parts[3], $archPat)
        $pyVersion = $parts[0] -replace '\-V:',''

        $pyVersionMajor = ($pyVersion -split '\.')[0]
        if(($FilterVersion -eq '3') -and $pyVersionMajor -eq '2'){
            continue
        }
        elseif(($FilterVersion -eq '2') -and $pyVersionMajor -eq '3'){
            continue
        }

        if($InsertLeadingV) { $pyVersion = "v"+$pyVersion }

        $pyLabel = ($parts[1] + ' ' + $parts[2] + ' ' + $parts[3]).Trim()
        $pyArch = ($archMatch.Success) ? $($archMatch.Groups[1].Value) : 'None'

        $line = $PY2[$idx] -replace '\* ', ''
        $parts = -split $line
        $finalPath = ''
        $pathIdx = 0
        $parts | ForEach-Object {
            if($pathIdx -ne 0) { $finalPath += $($_ + ' ') }
            $pathIdx++
        }
        $pyPath = $finalPath

        $Results = [PSCustomObject]@{
            Label = $pyLabel
            Version = $pyVersion
            Path = $pyPath
            Arch = $pyArch
        }

        $pythonObjects.Add($Results)
    }

    if($PathOnly){
        if($GetLatestOnly){ $pythonObjects[0].Path }
        elseif($GetOldestOnly){ $pythonObjects[$($pythonObjects.Count - 1)].Path }
        else {
            $pythonObjects | ForEach-Object {
                $_.Path
            }
        }
        return
    }

    if($VersionOnly){
        if($GetLatestOnly){ $pythonObjects[0].Version }
        elseif($GetOldestOnly){ $pythonObjects[$($pythonObjects.Count - 1)].Version }
        else {
            $pythonObjects | ForEach-Object {
                $_.Version
            }
        }
        return
    }

    if($GetLatestOnly){
        $pythonObjects[0]
        return
    }

    if($GetOldestOnly){
        $pythonObjects[$($pythonObjects.Count - 1)]
        return
    }

    $pythonObjects
    
    # if($NoTable){
    #     $pythonObjects
    # }else{
    #     Format-SpectreTable -Data $pythonObjects -Border Square Grey39
    # }
}

Get-PythonVersions 