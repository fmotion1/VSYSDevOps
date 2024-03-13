using namespace Globalization
function Format-StringRemoveDiacritics {
    [CmdletBinding()]
    Param (
        [ValidateNotNullOrEmpty()]
        [Alias('t')]
        [String]
        $Text,
        [System.Text.NormalizationForm]
        $NormalizationForm = "FormD"
    )

    foreach ($StringValue in $Text) {
        $Normalized = $StringValue.Normalize($NormalizationForm)
        $sb = New-Object Text.StringBuilder
        $normalized.ToCharArray() | % {
            if ( [CharUnicodeInfo]::GetUnicodeCategory($_) -ne [UnicodeCategory]::NonSpacingMark) {
                [void]$sb.Append($_)
            }
        }
        $sb.ToString()
    }
}