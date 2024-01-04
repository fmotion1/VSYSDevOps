using namespace System.Text.RegularExpressions
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

        $VENVOriginalPython = "Not Found"
        $VENVIncludeSystemPackages = "Not Found"
        $VENVPythonVersion = "Not Found"

        try { 

            $PythonVenvCfg = [System.IO.Path]::Combine($Folder, 'pyvenv.cfg')
            $DirectoryIsVENV = Test-Path -LiteralPath $PythonVenvCfg -PathType Leaf
            if(!$DirectoryIsVENV){
                Write-Error "The directory specified is not a Python VENV. (Missing pyvenv.cfg)"
                return
            }

            $PythonVenvFolder = $Folder

            $PythonExe = [System.IO.Path]::Combine($Folder, 'Scripts', 'python.exe')
            if(-not($PythonExe | Test-Path)){
                $PythonExe = "Not Found"
            }

            $PythonDebugExe = [System.IO.Path]::Combine($Folder, 'Scripts', 'python_d.exe')
            if(-not($PythonDebugExe | Test-Path)){
                $PythonDebugExe = "Not Found"
            }
            
            $PythonActivatePS1 = [System.IO.Path]::Combine($Folder, 'Scripts', 'Activate.ps1')
            if(-not($PythonActivatePS1 | Test-Path)){
                $PythonActivatePS1 = "Not Found"
            }

            $PythonActivateBAT = [System.IO.Path]::Combine($Folder, 'Scripts', 'activate.bat')
            if(-not($PythonActivateBAT | Test-Path)){
                $PythonActivateBAT = "Not Found"
            }

            $PythonDeactivateBAT = [System.IO.Path]::Combine($Folder, 'Scripts', 'deactivate.bat')
            if(-not($PythonDeactivateBAT | Test-Path)){
                $PythonDeactivateBAT = "Not Found"
            }

            $PythonSitePKG = [System.IO.Path]::Combine($Folder, 'Lib', 'site-packages')
            if(-not($PythonSitePKG | Test-Path)){
                $PythonSitePKG = "Not Found"
            }

            $PythonPipExe = [System.IO.Path]::Combine($Folder, 'Scripts', 'pip.exe')
            if(-not($PythonPipExe | Test-Path)){
                $PythonPipExe = "Not Found"
            }

            if(-not($PythonActivatePS1 | Test-Path)){
                Write-Error "VENV is missing Activate.ps1"
            }else{
                Push-Location $Folder -StackName VENV
                & $PythonActivatePS1
            }
            
            $PipCmd = Get-Command $PythonPipExe -CommandType Application
            $PythonPipVersion = "Unknown"
            $PipParams = "--version"
            $PipVersionString = & $PipCmd $PipParams
            [regex]$re = [regex]::new('\b(\d+\.\d+\.\d+)\b', [RegexOptions]::Compiled)
            $PythonPipVersion = $re.Match($PipVersionString)
            if(-not($PythonPipVersion)){
                Write-Error "Can't determine PIP version. pip --version returned an invalid result."
                $PythonPipVersion = "Unknown"
            }

            $PythonConfigLines = Get-Content -Path $PythonVenvCfg
            foreach ($Line in $PythonConfigLines) {
                if ($Line -match '^home\s*=\s*(.*)') {
                    $VENVOriginalPython = $matches[1].Trim()
                } elseif ($Line -match '^version\s*=\s*(.*)') {
                    $VENVPythonVersion = $matches[1].Trim()
                } elseif ($Line -match '^include-system-site-packages\s*=\s*(.*)') {
                    $VENVIncludeSystemPackages = $matches[1].Trim()
                }
            }

            $ScriptsContents = Join-Path $Folder -ChildPath "Scripts"
            $PythonScriptsContents = Get-ChildItem $ScriptsContents
            if(-not($PythonScriptsContents)){
                Write-Error "Python Scripts folder is Empty."
                $PythonScriptsContents = @("Error: Not Found")
            }

            & $PythonDeactivateBAT
            Pop-Location -StackName VENV

            [VSYSDevOps.Python.PythonVENVObject]@{
                IsVENV                  = $DirectoryIsVENV
                VENVPath                = $PythonVenvFolder
                PythonVersion           = $VENVPythonVersion
                PythonHome              = $VENVOriginalPython
                ActivateFilePS1         = $PythonActivatePS1
                ActivateFileBAT         = $PythonActivateBAT
                DeactivateBAT           = $PythonDeactivateBAT
                SitePackages            = $PythonSitePKG
                PythonBinary            = $PythonExe
                PythonDebugBinary       = $PythonDebugExe
                PIPBinary               = $PythonPipExe
                PIPVersion              = $PythonPipVersion
                IncludeSystemPackages   = $VENVIncludeSystemPackages
                ConfigFile              = $PythonVenvCfg
                ScriptsContent          = $PythonScriptsContents
            }

        } catch {

            $PSCmdlet.ThrowTerminatingError($PSItem)

        }
    }
}

Get-PythonVENVDetails -Folder "D:\Dev\Python\00 VENV\FontTools"