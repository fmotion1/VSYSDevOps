class ValidateSpectreTableBorder : System.Management.Automation.ValidateArgumentsAttribute 
{
    ValidateSpectreTableBorder() : base() { }
    [void]Validate([object] $Border, [System.Management.Automation.EngineIntrinsics]$EngineIntrinsics) {
        $spectreTableBorder = [Spectre.Console.TableBorder] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
        $result = $spectreTableBorder -contains $Border
        if($result -eq $false) {
            throw "'$Border' is not in the list of valid Spectre colors ['$($spectreTableBorder -join ''', ''')']" 
        }
    }
}

class ArgumentCompletionsSpectreTableBorder : System.Management.Automation.ArgumentCompleterAttribute 
{
    ArgumentCompletionsSpectreTableBorder() : base({
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        $options = [Spectre.Console.TableBorder] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
        return $options | Where-Object { $_ -like "$wordToComplete*" }
    }) { }
}