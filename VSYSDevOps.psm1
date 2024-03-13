$Public = Get-ChildItem $PSScriptRoot\Public -Recurse -Include '*.ps1','*.psm1' -ea SilentlyContinue
$Private = Get-ChildItem $PSScriptRoot\Private -Recurse -Include '*.ps1','*.psm1' -ea SilentlyContinue

foreach ($Import in @($Public + $Private)) {
    try { . $Import.FullName } catch {
        Write-Error -Message "Failed to import public function $($Import.FullName): $_"
    }
}