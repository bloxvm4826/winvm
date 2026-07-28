'TAG:T1785259824'
# noVNC listener check
$p = (Get-NetTCPConnection -State Listen -EA 0 | Where-Object { $_.LocalPort -in 6080,5900,3389 } | Select-Object -Expand LocalPort -Unique) -join ","
"listening: $p"
if (-not (Test-Path C:\cloudflared.exe)) {
  irm "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe" -OutFile C:\cloudflared.exe
}
"cf size: " + (Get-Item C:\cloudflared.exe).Length
# RustDesk ID as a backup route (needs the cmd redirect; direct call prints nothing)
$rd = "C:\Program Files\RustDesk\rustdesk.exe"
if (Test-Path $rd) { cmd /c "`"$rd`" --get-id > C:\id.txt 2>&1"; "rustdesk id: " + ((Get-Content C:\id.txt -EA 0) -join "") } else { "no rustdesk" }
