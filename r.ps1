$ErrorActionPreference = 'Continue'
$exe = 'C:\Program Files\RustDesk\rustdesk.exe'
if (-not (Test-Path $exe)) {
  Write-Host 'downloading rustdesk...'
  Invoke-WebRequest 'https://github.com/rustdesk/rustdesk/releases/download/1.3.9/rustdesk-1.3.9-x86_64.exe' -OutFile 'C:\rd.exe'
  Start-Process 'C:\rd.exe' -ArgumentList '--silent-install' -Wait
  Start-Sleep 25
}
Start-Service RustDesk -ErrorAction SilentlyContinue
Start-Sleep 5
& $exe --password 'BlxVm2026rd' | Out-Null
Start-Sleep 6
$paths = @(
  'C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk\config\RustDesk.toml',
  "$env:APPDATA\RustDesk\config\RustDesk.toml"
)
foreach ($p in $paths) {
  if (Test-Path $p) {
    $id = (Select-String -Path $p -Pattern "^\s*id\s*=" | Select-Object -First 1).Line
    Write-Host ">>> $id"
  }
}
Start-Process $exe
Write-Host '>>> done'
