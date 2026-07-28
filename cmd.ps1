'TAG:T1785259733'
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*play3.ps1*" -or $_.CommandLine -like "*play2.ps1*" } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -EA 0 }
$t=[int](Get-Date -UFormat %s)
irm "https://raw.githubusercontent.com/bloxvm4826/winvm/main/play4.ps1?t=$t" -OutFile C:\play4.ps1
Remove-Item C:\play4.log -EA 0
Start-Process powershell -ArgumentList "-ExecutionPolicy","Bypass","-WindowStyle","Hidden","-File","C:\play4.ps1","-Minutes","215" -WindowStyle Hidden
Start-Sleep -m 3000
"keepalive: " + ((Get-Content C:\play4.log -EA 0) -join " / ")
