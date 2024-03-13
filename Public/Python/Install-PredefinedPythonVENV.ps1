function Install-PythonPredefinedVENV {

    [CmdletBinding()]
    param(
        [parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("Folder")]
        [string] $Path,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('fonttools','imageops', IgnoreCase = $true)]
        [String] $VenvName,

        [String] $AccentColor = "#8B9BF4",
        [String] $TextColor = "#A1ACBA"
    )

    begin {

        $VenvList = [System.Collections.Generic.List[hashtable]]@()
        $VenvRequirementsFolder = "$PSModuleRoot\templates\python_venv_requirements\"

        $hFontTools =  @{ ID = 'fonttools'; Version='3.12'; Requirements = 'fonttools.txt'; Name = 'FontTools' }
        $hImageOps  =  @{ ID = 'imageops';  Version='3.12'; Requirements = 'imageops.txt'; Name = 'ImageOps' }

        $VenvList.Add($hFontTools)
        $VenvList.Add($hImageOps)

        Push-Location -LiteralPath $Path

    }

    process {

        $CurrentVenv        =  $VenvList | Where-Object {$_.ID -eq $VenvName}
        $CurrentVenvReq     =  Join-Path $VenvRequirementsFolder -ChildPath $CurrentVenv.Requirements
        $CurrentVenvName    =  $CurrentVenv.Name
        $CurrentVenvVersion =  $CurrentVenv.Version

        Write-SpectreHost "[$TextColor]Using Python [$AccentColor]v$CurrentVenvVersion[/][/]"
        Write-SpectreHost "[$TextColor]Initializing the virtual environment [$AccentColor]$CurrentVenvName[/][/]"

        try {
            $PyLauncher = Get-Command py.exe
        } catch {
            Write-Error "Can't find py.exe (Python Version Manager)"
            throw $_
        }

        $Params = "-$CurrentVenvVersion", '-m', 'venv', $Path
        & $PyLauncher $Params | Out-Null
        & "Scripts/Activate.ps1"

        Write-SpectreHost "[$TextColor]Upgrading [$AccentColor]PIP[/] to the latest version.[/]"
        python -m pip install --upgrade pip

        Write-SpectreHost "[$TextColor]Installing [$AccentColor]$CurrentVenvName[/] Dependencies.[/]"
        python -m pip install -r $CurrentVenvReq

        Write-SpectreHost "[$AccentColor]$CurrentVenvName[/] Installation Complete.`n"

    }
}