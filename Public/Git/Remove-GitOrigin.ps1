function Remove-GitOrigin {
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string[]] $Folder
    )

    process {
        foreach ($F in $Folder) {
            $result = New-Object PSObject -Property @{
                OriginURL = $null
                Branches  = @() # This will now hold an array of branches
                Success   = $false
            }

            Push-Location -Path $F -ErrorAction SilentlyContinue

            try {
                git status > $null 2>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-Warning "The folder '$F' is not a git repository."
                    continue
                }

                $originUrl = git config --get remote.origin.url
                if (-not $originUrl) {
                    Write-Warning "No remote named 'origin' exists in '$F'."
                    continue
                }
                $result.OriginURL = $originUrl

                # Retrieve branches tracking the origin
                $trackingBranches = git branch -r | Where-Object { $_ -match '^origin/' } | ForEach-Object { $_ -replace '^origin/', '' }
                if ($trackingBranches) {
                    $result.Branches = $trackingBranches
                }

                # Remove the origin
                git remote remove origin > $null 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $result.Success = $true
                } else {
                    Write-Warning "Failed to remove 'origin' from '$F'."
                }
            } catch {
                Write-Warning "An error occurred processing '$F'."
            } finally {
                Pop-Location
            }

            $result
        }
    }
}
