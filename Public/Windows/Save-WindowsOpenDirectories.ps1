function Save-WindowsOpenDirectories {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,Position=0)]
        [String]$DestinationFile
    )

    if([String]::IsNullOrEmpty($DestinationFile)){
        $DestinationFile = Join-Path $PWD -ChildPath "OpenExplorerWindows.txt"
    }
    elseif(-not(Test-PathIsLikelyFile -Path $DestinationFile)){
        throw "DestinationFile is an invalid filename."
    }

    $DPath = Get-UniqueFileOrFolderNameIfDuplicate -LiteralPath $DestinationFile
    New-Item -Path $DPath -ItemType File -Force | Out-Null

    [Array] $oWindows = Get-WindowsOpenDirectories
    $oWindows | ForEach-Object {
        if(-not([String]::IsNullOrEmpty($_))){
            $_ | Add-Content -Path $DPath
        }
    }
}