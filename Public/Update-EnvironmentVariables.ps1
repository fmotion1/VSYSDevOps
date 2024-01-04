<#
.SYNOPSIS
    Updates the PATH environment variable.

.DESCRIPTION
    The Update-EnvironmentVariables function updates the PATH environment variable by concatenating the system and user PATH variables. 
    It has an optional Quiet switch that, when used, suppresses the output message.

.PARAMETER Quiet
    An optional switch that, when used, suppresses the output message.

.EXAMPLE
    Update-EnvironmentVariables

    This command updates the PATH environment variable and displays a message.

.EXAMPLE
    Update-EnvironmentVariables -Quiet

    This command updates the PATH environment variable without displaying a message.

.NOTES
    This function updates the PATH environment variable for the current PowerShell session. 
    It does not permanently change the system or user PATH variables.
#>
function Update-EnvironmentVariables {
    
    param (
        [Switch] $Quiet
    )

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + 
                [System.Environment]::GetEnvironmentVariable("Path","User")

    if(!$Quiet){
        Write-SpectreHost "[#FFFFFF]Environment Variables have been Reloaded.[/]"
    }
}