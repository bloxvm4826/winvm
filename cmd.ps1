$exe='C:\Program Files\RustDesk\rustdesk.exe'
cmd /c "`"$exe`" --get-id > C:\id.txt 2>&1"
Start-Sleep 6
if (Test-Path C:\id.txt) { "GETID:[" + ((Get-Content C:\id.txt -Raw).Trim()) + "]" } else { "no id.txt" }
& $exe --password 'BlxVm2026rd' | Out-String
"ver: " + (Get-Item $exe).VersionInfo.FileVersion
