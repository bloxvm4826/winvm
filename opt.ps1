$ErrorActionPreference = "SilentlyContinue"
Write-Host "=== FREE CPU ==="
Stop-Service tvnserver -Force
Get-Process | Where-Object { $_.ProcessName -match 'python|websockify|tvnserver' } | Stop-Process -Force
Write-Host ("cpu=" + [math]::Round((Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average,0) + "% cores=" + $env:NUMBER_OF_PROCESSORS)
$os = Get-CimInstance Win32_OperatingSystem
Write-Host ("freeMB=" + [math]::Round($os.FreePhysicalMemory/1024,0) + " totalMB=" + [math]::Round($os.TotalVisibleMemorySize/1024,0))

Write-Host "=== INSTALL ROBLOX PLAYER ==="
$exe = "$env:LOCALAPPDATA\Roblox\Versions"
if (Test-Path $exe) {
  $p = Get-ChildItem $exe -Recurse -Filter RobloxPlayerBeta.exe | Select-Object -First 1
  if ($p) { Write-Host "already installed: $($p.FullName)" }
}
if (-not $p) {
  $dl = "$env:TEMP\RobloxPlayerInstaller.exe"
  Invoke-WebRequest -Uri "https://www.roblox.com/download/client?os=win" -OutFile $dl -UseBasicParsing
  Write-Host ("downloaded " + [math]::Round((Get-Item $dl).Length/1MB,1) + " MB")
  Start-Process $dl
  Write-Host "installer started, waiting..."
  for ($i=0; $i -lt 60; $i++) {
    Start-Sleep 5
    $p = Get-ChildItem "$env:LOCALAPPDATA\Roblox\Versions" -Recurse -Filter RobloxPlayerBeta.exe -EA 0 | Select-Object -First 1
    if ($p) { break }
  }
  if ($p) { Write-Host "INSTALLED: $($p.FullName)" } else { Write-Host "INSTALL FAILED" }
}
Get-Process RobloxPlayerBeta -EA 0 | Select-Object Id,StartTime | Format-Table
Write-Host "=== DONE ==="
