using namespace System.Management.Automation

class NodeVersions : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $v = Get-NodeVersionsWithNVM -VersionOnly
        return $v
    }
}

function Install-NodeGlobalPackages {
    param(
        [Parameter(Mandatory)]
        [ValidateSet([NodeVersions])]
        $Version,

        [Parameter(Mandatory=$false)]
        [Switch]
        $Prompt,

        [Parameter(Mandatory,ValueFromRemainingArguments)]
        [String[]]
        $Packages

    )

    if($Prompt){
        $PackagesList = $Packages
        $Plural = 'package'
        if($Packages.Count -gt 1){
            $Plural = 'packages'
            $PackagesList = $Packages -join ', '
        }
        Write-SpectreHost "The $Plural [white]$PackagesList[/] will be installed in the following node version: [white]$Version[/]"
        $Result = Read-Host "Do you want to continue? [Y]"
        if($Result -ne 'y') { exit }
    }

    & nvm use $Version
    $cmd = Get-Command npm.cmd
    & $cmd install -g $Packages.Trim()
}