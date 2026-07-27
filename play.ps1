param(
  [int]$Minutes = 30,
  [int]$JoyX = 383,      # CloudMoon on-screen joystick centre, REMOTE 1600x900 coords
  [int]$JoyY = 585,
  [int]$Radius = 62,
  [int]$LegMs = 2600     # how long to hold each direction
)

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class M {
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint dx, uint dy, uint d, int e);
  public const uint DOWN = 0x0002, UP = 0x0004;
  public static void Press()   { mouse_event(DOWN,0,0,0,0); }
  public static void Release() { mouse_event(UP,0,0,0,0); }
}
"@

function Hold-Joy([double]$deg, [int]$ms) {
  $rad = $deg * [Math]::PI / 180.0
  $tx = [int]($JoyX + [Math]::Sin($rad) * $Radius)
  $ty = [int]($JoyY - [Math]::Cos($rad) * $Radius)
  [M]::SetCursorPos($JoyX, $JoyY); Start-Sleep -Milliseconds 90
  [M]::Press();                    Start-Sleep -Milliseconds 120
  # ease out to the target so the game registers the stick deflection
  for ($i = 1; $i -le 6; $i++) {
    [M]::SetCursorPos([int]($JoyX + ($tx-$JoyX)*$i/6), [int]($JoyY + ($ty-$JoyY)*$i/6))
    Start-Sleep -Milliseconds 25
  }
  Start-Sleep -Milliseconds $ms
  [M]::Release()
  Start-Sleep -Milliseconds 220
}

$end = (Get-Date).AddMinutes($Minutes)
$dirs = @(0, 45, 90, 135, 180, 225, 270, 315)
$i = 0
$laps = 0
Write-Host "autoplay start -> $end  joy=($JoyX,$JoyY) r=$Radius"
while ((Get-Date) -lt $end) {
  # walk a widening then narrowing circuit so the whole base plot gets swept
  $d = $dirs[$i % $dirs.Count]
  $len = if (($laps % 2) -eq 0) { $LegMs } else { [int]($LegMs * 0.6) }
  Hold-Joy $d $len
  $i++
  if (($i % $dirs.Count) -eq 0) {
    $laps++
    Write-Host ("lap {0} {1:HH:mm:ss}" -f $laps, (Get-Date))
  }
}
Write-Host "autoplay done"
