Add-Type -AssemblyName System.Windows.Forms
Set-Clipboard -Value 'somanyalts30@gmail.com'
CClick 796 449
Start-Sleep 1
[System.Windows.Forms.SendKeys]::SendWait("^a")
[System.Windows.Forms.SendKeys]::SendWait("^v")
Start-Sleep 1
Set-Clipboard -Value 'Azerty060809*'
CClick 796 519
Start-Sleep 1
[System.Windows.Forms.SendKeys]::SendWait("^a")
[System.Windows.Forms.SendKeys]::SendWait("^v")
Start-Sleep 1
"typed creds"
