function Confirm-FolderIsPythonVENV {
    param (
        [string[]] $Folder
    )

    foreach ($F in $Folder) {

        $pyvenvcfg = [System.IO.Path]::Combine($F, 'pyvenv.cfg')
        if(Test-Path -LiteralPath $pyvenvcfg -PathType Leaf){

            $true

        } else {

            $false
            
        }
    }
}