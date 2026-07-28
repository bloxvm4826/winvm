# War Tycoon grinder v3 - respawn-anchored radial sorties.
# Respawn is a reliable teleport to a KNOWN open spot, and the joystick is
# camera-relative, so a fixed angle after each respawn = a repeatable world
# direction. That gives deterministic coverage instead of random wedging.
param([int]$Minutes = 60)
. C:\l.ps1
if (-not ("K" -as [type])) {
  Add-Type "using System;using System.Runtime.InteropServices;public class K { [DllImport(\"user32.dll\")] public static extern void keybd_event(byte v, byte s, uint f, int e); }"
}
function Key([byte]$vk,[int]$hold=60){ [K]::keybd_event($vk,0,0,0); Start-Sleep -m $hold; [K]::keybd_event($vk,0,2,0); Start-Sleep -m 250 }
function Log($m){ "$(Get-Date -F HH:mm:ss) $m" | Out-File C:\play3.log -Append -Encoding utf8 }
# Clears a Roblox "Buy Robux" modal. ESC closes the prompt and opens the menu,
# so the 2nd ESC closes that. Net no-op when nothing is up.
function Unstick { Key 0x1B; Start-Sleep -m 700; Key 0x1B; Start-Sleep -m 600 }
function Respawn {
  Click 346 124 250; Start-Sleep -m 900
  Click 365 430 250; Start-Sleep -m 900
  Click 681 476 250; Start-Sleep -m 4200   # confirm
  Click 346 124 250; Start-Sleep -m 800    # menu stays open after respawn
}
$end = (Get-Date).AddMinutes($Minutes)
Log "START v3 until $end"
Act
$angles = @(0,30,60,90,120,150,180,210,240,270,300,330)
$n = 0
while ((Get-Date) -lt $end) {
  foreach ($a in $angles) {
    if ((Get-Date) -ge $end) { break }
    $n++
    Respawn
    Unstick                      # spawn area itself can hold a stale modal
    Joy $a 2600                  # walk outward along this ray
    Unstick                      # a pad may have fired mid-walk
    Joy $a 2600                  # keep going further out
    Joy ($a+20) 1500             # slight fan so we brush nearby pads
    Unstick
    Log "sortie $n angle $a"
  }
}
Log "DONE"
