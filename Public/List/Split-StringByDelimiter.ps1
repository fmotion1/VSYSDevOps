function Split-StringByDelimiter {

    [CmdletBinding()]
    [OutputType([String], [String[]], [PSCustomObject])]

    param (

        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $InputString,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Delimiter,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Array', 'String', 'Object', IgnoreCase = $true)]
        [string] $OutputType = 'Array',

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('None', 'Leading', 'Trailing', 'Both', IgnoreCase = $true)]
        [string] $WhitespaceTrimming = 'Both',

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch] $IncludeEmptyStrings,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch] $IncludeNewlines,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch] $Regex,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch] $CaseSensitive,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int] $MaxSplit = [int]::MaxValue

    )

    process {

        if (-not $IncludeNewlines) {
            $InputString = $InputString -replace "`r`n", "" -replace "`n", ""
        }

        switch ($WhitespaceTrimming) {
            'Both' { $InputString = $InputString.Trim(); break }
            'Leading' { $InputString = $InputString.TrimStart(); break }
            'Trailing' { $InputString = $InputString.TrimEnd(); break }
        }

        $Delim = ($Regex) ? $Delimiter : ([regex]::Escape($Delimiter))
        $splitOptions = ($CaseSensitive) ? 'None' : 'IgnoreCase'
        $splitStrings = $InputString -split $Delim, $MaxSplit, $splitOptions

        if ($WhitespaceTrimming -ne 'None') {
            $splitStrings = $splitStrings | ForEach-Object {
                $splitStr = $_

                switch ($WhitespaceTrimming) {
                    'Both' { $splitStr.Trim(); break }
                    'Leading' { $splitStr.TrimStart(); break }
                    'Trailing' { $splitStr.TrimEnd(); break }
                    default { $splitStr }
                }
            }
        }

        if (-not $IncludeEmptyStrings) {
            $splitStrings = $splitStrings | Where-Object { $_ -ne '' }
        }

        $resultObj = $null
        if ($OutputType -eq 'String') {
            $resultObj = $splitStrings -join "`r`n"
        } elseif ($OutputType -eq 'Array') {
            $resultObj = $splitStrings
        } elseif ($OutputType -eq 'Object') {
            $resultObj =
            [PSCustomObject][Ordered]@{
                InputString         =  $InputString
                Delimiter           =  $Delim
                WhitespaceTrimming  =  $WhitespaceTrimming
                IncludeEmptyStrings =  $IncludeEmptyStrings.IsPresent
                IncludeNewlines     =  $IncludeNewlines.IsPresent
                RegexUsed           =  $Regex.IsPresent
                CaseSensitive       =  $CaseSensitive.IsPresent
                MaxSplit            =  $MaxSplit
                ResultArray         =  $splitStrings
                ResultString        =  $splitStrings -join "`r`n"
            }
        }

        return $resultObj
    }
}