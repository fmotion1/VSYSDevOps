function Get-PythonVENVDetails {
    [CmdletBinding()]
    [OutputType([VSYSDevOps.Python.PythonVENVObject])]
    param (
        [Parameter(Mandatory)]
        [Alias("f")]
        [String]
        $Folder
    )

    process {

        if(-not(Test-Path -LiteralPath $Folder -PathType Container)){
            Write-Error "Folder doesn't exist. Check your spelling and try again."
            return
        }

        $DirectoryIsVENV = $false
        $VENVOriginalPython = $null
        $VENVIncludeSystemPackages = $null
        $VENVPythonVersion = $null

        try { 

            $pyvenvcfg = [System.IO.Path]::Combine($Folder, 'pyvenv.cfg')
            $DirectoryIsVENV = Test-Path -LiteralPath $pyvenvcfg -PathType Leaf
            
            if(!$DirectoryIsVENV){
                Write-Error "The directory specified is not a Python VENV. (Missing pyvenv.cfg)"
                return
            }

            $ConfigLines = Get-Content -Path $pyvenvcfg
        
            foreach ($Line in $ConfigLines) {
                if ($Line -match '^home\s*=\s*(.*)') {
                    $VENVOriginalPython = $matches[1].Trim()
                } elseif ($Line -match '^version\s*=\s*(.*)') {
                    $VENVPythonVersion = $matches[1].Trim()
                } elseif ($Line -match '^include-system-site-packages\s*=\s*(.*)') {
                    $VENVIncludeSystemPackages = $matches[1].Trim()
                }
            }

            $VENVPath = $Folder
            $VENVOriginalPython
            $PyExe = [System.IO.Path]::Combine($Folder, 'Scripts', 'python.exe')
            $PipExe = [System.IO.Path]::Combine($Folder, 'Scripts', 'pip.exe')
            $SitePKG = [System.IO.Path]::Combine($Folder, 'Lib', 'site-packages')
            $PYCFG = $pyvenvcfg

            [VSYSDevOps.Python.PythonVENVObject]@{
                IsVENV                = $DirectoryIsVENV
                VENVPath              = $VENVPath
                PythonVersion         = $VENVPythonVersion
                PythonHome            = $VENVOriginalPython
                SitePackages          = $SitePKG
                IncludeSystemPackages = $VENVIncludeSystemPackages
                PythonBinary          = $PyExe
                PIPBinary             = $PipExe
                ConfigFile            = $PYCFG
            }

        } catch {

            $PSCmdlet.ThrowTerminatingError($PSItem)

        }
    }
}