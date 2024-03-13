function Confirm-FolderIsGitRepository {

    [OutputType([System.Boolean])]
    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String] $Folder
    )

    process {

        if (-not (Test-Path -LiteralPath $Folder -PathType Container)) {
            Write-Error -Message "Folder '$Folder' doesn't exist. Aborting."
            return
        }

        # Ensure the folder path ends with the correct directory separator
        $separator = [System.IO.Path]::DirectorySeparatorChar
        if (-not($Folder.EndsWith($separator))) {
            $Folder += $separator
        }

        $git = [System.IO.Path]::Combine($Folder, '.git')
        if (Test-Path -LiteralPath $git -PathType Container) { $true } else { $false }
    }
}