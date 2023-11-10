using namespace System.Management.Automation

class NodeVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-NodeVersionsWithNVM -VersionOnly
        return $v
    }
}

function Invoke-InteractiveNewNodeProject {

    param (
        [Parameter(Mandatory,Position=0)]
        [String]
        $Folder,
    
        [Parameter(Mandatory=$false)]
        [ValidateSet([NodeVersions])]
        [String]
        $Version
    )

    Push-Location -LiteralPath $Folder -StackName NodeInit

    Set-SpectreColors -AccentColor "#5F97F7" -DefaultValueColor "#FFFFFF"

    $i = Get-ChildItem -Path $Folder
    if ($i.Count -ne 0) {
        Read-SpectrePause -Message "[#EF6781]ERROR:[/] The current directory is not empty. Press any key to exit."
        Pop-Location -StackName NodeInit
        return
    }

    if([String]::IsNullOrWhiteSpace($Version)){

        $Versions = Get-NodeVersionsWithNVM -VersionOnly -Branch CURRENT -InsertLeadingV
        Write-SpectreHost -Message "[white]No version of Node was passed.[/]"
        $TargetVersion = Read-SpectreSelection -Title "Select the version of [white]NodeJS[/] that you want to deploy." -Choices $Versions

        $DoContinue = Read-SpectreConfirm -Prompt "You selected [white]$TargetVersion[/]. Do you want to continue?`n" -DefaultAnswer y
        if(!$DoContinue){
            return
        }
        $Version = $TargetVersion.TrimStart('v')

    } else {

        Write-SpectreHost -Message "Setting up a new Node.js environment with target version [white]v$Version[/]`n"
        $DoContinue = Read-SpectreConfirm -Prompt "Do you want to continue?" -DefaultAnswer y
        if(!$DoContinue){
            return
        }
        
    }

    Write-Host "`n"
    $NVMCmd = Get-Command nvm.exe
    & $NVMCmd use $Version | Out-Null

    $NPMCmd = Get-Command npm.cmd
    & $NPMCmd init -y

    '' | Out-File -LiteralPath "$Folder/index.js" -Force

    $DoGitRepo = Read-SpectreConfirm -Prompt "Would you like to initialize a git repository?" -DefaultAnswer y
    if($DoGitRepo -eq $true){
        $Templates = @('Empty','VSYS','Minimal')
        $GitIgnoreTemplate = Read-SpectreSelection -Title "Select your gitignore template:" -Choices $Templates
        Write-SpectreHost "Saving [white]gitignore[/] template and initializing...`n"
        Save-GitignoreToFolder -Folder $Folder -Template $GitIgnoreTemplate -Force
        $GITCmd = Get-Command git.exe
        & $GITCmd init
    }

    Write-SpectreHost "[white]Your environment has been set up now.[/] Press any key to continue...`n"
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}