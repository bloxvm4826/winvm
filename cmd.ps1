'TAG:T1785258425'
$t=[int](Get-Date -UFormat %s)
irm "https://raw.githubusercontent.com/bloxvm4826/winvm/main/play2.ps1?t=$t" -OutFile C:\play2.ps1
Remove-Item C:\play2.log -EA 0
Start-Process powershell -ArgumentList "-ExecutionPolicy","Bypass","-WindowStyle","Hidden","-File","C:\play2.ps1","-Minutes","70" -WindowStyle Hidden
Start-Sleep -m 4000
"launched; log:"
if(Test-Path C:\play2.log){Get-Content C:\play2.log}else{"(no log yet)"}
