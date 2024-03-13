<#
.SYNOPSIS
    Generates a unique name for a file or folder if a duplicate name exists on disk.

.DESCRIPTION
    The Get-UniqueFileOrFolderNameIfDuplicate function generates a unique name for a file or folder by appending an index to the original name if a duplicate name exists on disk.
    The function supports both wildcard and literal paths, and allows customization of the index format.

.PARAMETER Path
    Specifies the paths to process. This parameter accepts pipeline input and can be a string, or an object with a Path, FullName, or PSPath property.

.PARAMETER LiteralPath
    Specifies the literal paths to process. This parameter accepts pipeline input and can be a string, or an object with a PSPath property. Wildcard characters are not acceptable with this parameter.

.PARAMETER PadIndexTo
    Specifies the number of digits to use for the index. The default is 2.

.PARAMETER IndexStart
    Specifies the starting number for the index. The default is 2.

.PARAMETER NoUnderscore
    If this switch is present, no underscore will be added before the index in the generated name.

.EXAMPLE
    Get-UniqueFileOrFolderNameIfDuplicate -Path "C:\Temp\*"

    This example generates unique names for all files and folders in the "C:\Temp" directory if a duplicate name exists on disk.

.EXAMPLE
    Get-UniqueFileOrFolderNameIfDuplicate -LiteralPath "C:\Temp\MyFile.txt" -PadIndexTo 3 -IndexStart 5

    This example generates a unique name for the "MyFile.txt" file in the "C:\Temp" directory if a duplicate name exists on disk, with a 3-digit index starting at 5.

.EXAMPLE
    Get-UniqueFileOrFolderNameIfDuplicate -Path "C:\Temp\MyFolder" -NoUnderscore

    This example generates a unique name for the "MyFolder" folder in the "C:\Temp" directory if a duplicate name exists on disk, without an underscore before the index.

.AUTHOR
    Futuremotion
    https://www.github.com/fmotion1
#>
function Get-UniqueFileOrFolderNameIfDuplicate {
    [cmdletbinding(DefaultParameterSetName = 'Path')]
    param(
        [parameter(
            Mandatory,
            ParameterSetName  = 'Path',
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]] $Path,
        [parameter(
            Mandatory,
            ParameterSetName = 'LiteralPath',
            Position = 0,
            ValueFromPipelineByPropertyName
        )]
        [ValidateScript({
            if ($_ -notmatch '[\?\*]') {
                $true
            } else {
                throw 'Wildcard characters *, ? are not acceptable with -LiteralPath'
            }
        })]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath')]
        [string[]] $LiteralPath,
        [Int32] $PadIndexTo = 2,
        [Int32] $IndexStart = 2,
        [switch] $AddUnderscore
    )

    process {

        $SerializeFileOrFolder = {
            param (
                [Parameter(Mandatory,Position=0)]
                [String] $Path,
                [int32] $PadIndexTo = 2
            )

            $PathToTest     =  $Path
            $IDX            =  $IndexStart
            $PadIndex       =  $PadIndexTo -as [String]
            $IndexSeparator =  ($AddUnderscore) ? '_' : ' '
            $IsDirectory    =  Test-Path -LiteralPath $PathToTest -PathType Container

            if (-not $IsDirectory) {
                $FileExtension = [System.IO.Path]::GetExtension($PathToTest)
                if([String]::IsNullOrEmpty($FileExtension)){
                    $FileHasNoExtension  = $true
                    $FilepathNoExtension = $PathToTest
                } else {
                    if ($PathToTest.Contains('.')) {
                        $FilepathNoExtension = $PathToTest.Substring(0, $PathToTest.LastIndexOf('.'))
                        if($FilepathNoExtension | Test-Path -PathType Container){
                            $FileIsDotfile = $true
                        }
                    }
                }
            } else {
                $CurrentPath = [System.IO.Path]::TrimEndingDirectorySeparator($PathToTest)
            }

            $PathType = ($IsDirectory) ? 'Container' : 'Leaf'
            while (Test-Path -LiteralPath $PathToTest) {
                switch ($PathType) {
                    'Container' {
                        $PathToTest = "{0}{1}{2:d$PadIndex}" -f $CurrentPath, $IndexSeparator, $IDX
                    }
                    'Leaf' {
                        if ($FileIsDotfile) {
                            $InitialPath = $FilepathNoExtension + $FileExtension
                            $PathToTest = "$InitialPath`_{0:d$PadIndex}" -f $IDX
                        } elseif (!$FileHasNoExtension) {
                            $PathToTest = "{0}{1}{2:d$PadIndex}{3}" -f $FilepathNoExtension, $IndexSeparator, $IDX, $FileExtension
                        } else {
                            $PathToTest = "{0}{1}{2:d$PadIndex}" -f $FilepathNoExtension, $IndexSeparator, $IDX
                        }
                    }
                }

                $IDX++
            }
            return $PathToTest
        }

        $Paths = if($PSCmdlet.ParameterSetName -eq 'Path') { $Path } else { $LiteralPath }
        $Paths | ForEach-Object {
            $P = $_
            foreach ($CurPath in $P) {
                # $CurrentPath = $CurPath.Path
                $FinalPath = & $SerializeFileOrFolder $CurPath -PadIndexTo $PadIndexTo
                $FinalPath
            }
        }
    }
}