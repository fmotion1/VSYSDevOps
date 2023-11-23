function Get-LicenseTemplates {
    [CmdletBinding()]
    param ()
    process {
        # Define the parent directory containing the folders
        $ParentDirectory = "$PSScriptRoot\..\Templates\LICENSE\"

        # Get the list of folders
        $Folders = Get-ChildItem -Path $ParentDirectory -Directory

        # Create an array of custom objects
        $FolderDetails = $Folders | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name  # Folder name
                Path = $_.FullName  # Full path of the folder
            }
        }

        return $FolderDetails | Sort-Object -Descending
    }
}

Get-LicenseTemplates