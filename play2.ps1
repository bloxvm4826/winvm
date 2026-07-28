# War Tycoon grinder v2 - fixes the two known stall modes:
#   (1) Roblox "Buy Robux" prompts lock all input  -> periodic double-ESC
#   (2) avatar wedges on interior walls            -> periodic Respawn
param([int]$Minutes = 60)
. C:\l.ps1
if (-not ("K" -as [type])) {
  Add-Type "using System;using System.Runtime.InteropServices;public class K { [DllImport(\"user32.dll\")] public static extern void keybd_event(byte v, byte s, uint f, int e); }"
}
function Key([byte]$vk,[int]$hold=60){ [K]::keybd_event($vk,0,0,0); Start-Sleep -m $hold; [K]::keybd_event($vk,0,2,0); Start-Sleep -m 250 }
function Log($m){ "$(Get-Date -F HH:mm:ss) $m" | Out-File C:\play2.log -Append -Encoding utf8 }
function Unstick { Key 0x1B; Start-Sleep -m 700; Key 0x1B; Start-Sleep -m 500 }   # kills a purchase prompt; no-op otherwise
function Respawn {
  Click 346 124 250; Start-Sleep -m 900
  Click 365 430 250; Start-Sleep -m 900
  Click 681 509 250; Start-Sleep -m 3500
  Log "respawned"
}
$end = (Get-Date).AddMinutes($Minutes)
Log "START v2 until $end"
Act
$dirs = @(0,45,90,135,180,225,270,315)
$lap = 0
while ((Get-Date) -lt $end) {
  $lap++
  # vary the circuit each lap so different pads get stepped on
  $order = $dirs | Sort-Object { Get-Random }
  foreach ($d in $order) {
    if ((Get-Date) -ge $end) { break }
    Joy $d (1200 + (Get-Random -Max 1600))
  }
  if ($lap % 2 -eq 0) { Unstick; Log "lap $lap unstick" }
  if ($lap % 4 -eq 0) { Respawn }
  if ($lap % 3 -eq 0) { Look (Get-Random -Min -250 -Max 250) }
  Log "lap $lap done"
}
Log "DONE"
