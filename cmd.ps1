Get-Service rustdesk -EA 0 | Select-Object Name,Status | Format-Table -Auto | Out-String
Get-Process rustdesk -EA 0 | Select-Object Id | Format-Table -Auto | Out-String
$t = Get-ChildItem 'C:\Windows\ServiceProfiles','C:\Users' -Recurse -Filter 'RustDesk.toml' -Force -EA 0
if (-not $t) { "NO TOML" } else { foreach ($f in $t) { $f.FullName; (Get-Content $f.FullName -Raw) } }
