function Save-GitignoreToFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Folder,
    
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateSet('vsys','minimal','empty', IgnoreCase = $true)]
        [String]
        $Template,
    
        [Parameter(Mandatory=$false)]
        [Switch]
        $Force
    )
    
    begin {
        switch ($Template.ToLower()) {
            "vsys"     {$GitignoreSource = "$PSScriptRoot\..\Templates\gitignore\vsys.gitignore" }
            "minimal"  {$GitignoreSource = "$PSScriptRoot\..\Templates\gitignore\minimal.gitignore"}
            "empty"    {$GitignoreSource = "$PSScriptRoot\..\Templates\gitignore\empty.gitignore"}
        }
    }
    
    process {

        $GitignorePath = Join-Path $Folder '.gitignore'
        $GitignoreExists = Test-Path -LiteralPath $GitignorePath -PathType Leaf

        if((!$GitignoreExists) -or $Force){
            [IO.File]::Copy($GitignoreSource, $GitignorePath, $true)
        }
    }
}
