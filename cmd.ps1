'TAG:T1785259976'
Get-Process cloudflared -EA 0 | Stop-Process -Force -EA 0
Remove-Item C:\cf.log,C:\cf.out -EA 0
Start-Process C:\cloudflared.exe -ArgumentList "tunnel","--url","http://localhost:6080","--no-autoupdate" -RedirectStandardError C:\cf.log -RedirectStandardOutput C:\cf.out -WindowStyle Hidden
Start-Sleep -Seconds 18
$u = (Select-String -Path C:\cf.log,C:\cf.out -Pattern "https://[a-z0-9-]+\.trycloudflare\.com" -EA 0 | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)
if ($u) { "TUNNEL: $u" } else { "no url yet; log tail: " + ((Get-Content C:\cf.log -Tail 6 -EA 0) -join " | ") }
