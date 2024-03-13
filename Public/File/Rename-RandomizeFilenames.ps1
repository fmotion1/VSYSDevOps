function Rename-RandomizeFilenames {
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
        [Object[]] $Path,

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
        [Object[]] $LiteralPath,

        [Int32] $MaxThreads = 12

    )

    begin {
        $List = [System.Collections.Generic.List[string]]@()
    }

    process {

        $Paths = if($PSCmdlet.ParameterSetName -eq 'Path') { $Path } else { $LiteralPath }

        foreach ($P in $Paths) {
            $Path = if ($P -is [String])  { $P }
                    elseif ($P.Path)	  { $P.Path }
                    elseif ($P.FullName)  { $P.FullName }
                    elseif ($P.PSPath)	  { $P.PSPath }
                    else { Write-Error "$P is an unsupported type."; throw }

            # Resolve paths
            $ResolvedPaths = Resolve-Path -Path $Path
            foreach ($ResolvedPath in $ResolvedPaths) {
                if (Test-Path -Path $ResolvedPath.Path -PathType Leaf) {
                    $List.Add($ResolvedPath.Path)
                } else {
                    Write-Warning "$ResolvedPath does not exist on disk."
                }
            }
        }
    }

    end {
        $List | ForEach-Object -Parallel {

            $CurrentFile = $_
            $RandomStr   = Get-RandomAlphanumericString -Length 20
            $NewFilename = $RandomStr + [System.IO.Path]::GetExtension($CurrentFile)

            Rename-Item -LiteralPath $_ -NewName $NewFilename -Force

        } -ThrottleLimit $MaxThreads
    }
}