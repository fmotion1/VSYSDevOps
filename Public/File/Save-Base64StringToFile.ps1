function Convert-Base64StringToFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [Alias("Input")]
        [String] $Base64Input,

        [parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [String] $OutputFile
    )

    begin {}

    process {
        try {
            $ContentBytes = [Convert]::FromBase64String($Base64String)
        } catch {
            throw "Couldn't decode input string."
        }

        $ContentBytes | Set-Content -Path $OutputFile -AsByteStream -Force | Out-Null
        [System.IO.FileInfo] $OutputFileObj = Get-Item -Path $OutputFile

        $OutputFileObj
    }

    end {}

}