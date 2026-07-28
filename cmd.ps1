'TAG:T1785258078'
(Get-ChildItem C:\ -Filter *.ps1 -EA 0|%{$_.Name+" "+$_.Length}) -join " | "
"---log---"
if(Test-Path C:\auto.log){(Get-Content C:\auto.log -Tail 4) -join " / "}else{"no auto.log"}
"---running---"
(Get-CimInstance Win32_Process -Filter "Name=$([char]39)pwsh.exe$([char]39) or Name=$([char]39)powershell.exe$([char]39)"|%{$_.ProcessId.ToString()+":"+($_.CommandLine -replace "\s+"," ").Substring(0,[Math]::Min(70,$_.CommandLine.Length))}) -join "`n"
