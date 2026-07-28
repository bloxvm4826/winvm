# Keepalive: CloudMoon disconnects after ~5-10 min without input, and a rejoin
# would reset base progress (it is per-server). So feed it tiny in-place nudges
# that never relocate the avatar, and clear stray modals periodically.
param([int]$Minutes = 240)
. C:\l.ps1
if (-not ("K" -as [type])) {
  Add-Type "using System;using System.Runtime.InteropServices;public class K { [DllImport(\"user32.dll\")] public static extern void keybd_event(byte v, byte s, uint f, int e); }"
}
function Key([byte]$vk,[int]$hold=60){ [K]::keybd_event($vk,0,0,0); Start-Sleep -m $hold; [K]::keybd_event($vk,0,2,0); Start-Sleep -m 250 }
function Log($m){ "$(Get-Date -F HH:mm:ss) $m" | Out-File C:\play4.log -Append -Encoding utf8 }
$end = (Get-Date).AddMinutes($Minutes)
Log "KEEPALIVE until $end"
$i = 0
while ((Get-Date) -lt $end) {
  $i++
  Act
  Joy 0 260; Start-Sleep -m 300; Joy 180 260     # forward + back = net zero
  if ($i % 6 -eq 0) { Key 0x1B; Start-Sleep -m 700; Key 0x1B; Log "tick $i unstick" }
  else { Log "tick $i" }
  Start-Sleep -Seconds 40
}
Log "KEEPALIVE DONE"
