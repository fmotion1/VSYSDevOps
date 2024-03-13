# REFACTOR: Optimize F5 portion. Code quality.
function Request-WindowsExplorerRefresh {
    param (
        [switch] $AlsoSendF5
    )

    $ComApp = New-Object -ComObject Shell.Application
    $ComAppWin = $ComApp.Windows()

    foreach ($Window in $ComAppWin) {
        if($Window.Name -eq "File Explorer"){
            $Window.Refresh()
        }
    }

    if($AlsoSendF5){
        $wshell = New-Object -ComObject wscript.shell;
        Start-Sleep -Milliseconds 100
        $wshell.SendKeys("{F5}")
        Start-Sleep -Milliseconds 150
        $wshell.SendKeys("{F5}")
    }
}