Add-Type -AssemblyName System.Windows.Forms
CClick 796 445
Start-Sleep 2
[System.Windows.Forms.SendKeys]::SendWait("{DOWN}{DOWN}{ENTER}")
Start-Sleep 2
"server keyboard-selected"
