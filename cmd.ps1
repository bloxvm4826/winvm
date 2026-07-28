Set-Content C:\bot.ps1 -Encoding UTF8 -Value @'
# Pad-seeking bot for War Tycoon on the CloudMoon stream (runs ON the winvm, 1600x900).
# Requires lib.ps1 (Act/Joy/Look/Click) already loaded.
Add-Type -AssemblyName System.Drawing

# Stream area on the desktop (CloudMoon canvas inside Chrome), remote coords.
$global:SX = 430; $global:SY = 140; $global:SW = 860; $global:SH = 560
$global:CHX = 800; $global:CHY = 430   # character on screen

function GreenTarget {
  $b = New-Object Drawing.Bitmap $global:SW, $global:SH
  $g = [Drawing.Graphics]::FromImage($b)
  $g.CopyFromScreen($global:SX, $global:SY, 0, 0, (New-Object Drawing.Size $global:SW, $global:SH))
  $w = 220; $h = [int]($global:SH * $w / $global:SW)
  $s = New-Object Drawing.Bitmap $w, $h
  $g2 = [Drawing.Graphics]::FromImage($s); $g2.DrawImage($b, 0, 0, $w, $h)
  $cx = ($global:CHX - $global:SX) * $w / $global:SW
  $cy = ($global:CHY - $global:SY) * $w / $global:SW
  $best = $null; $bd = 1e9; $n = 0
  for ($y = 2; $y -lt $h - 2; $y++) {
    for ($x = 2; $x -lt $w - 2; $x++) {
      $p = $s.GetPixel($x, $y)
      if ($p.G -gt 130 -and $p.R -lt 110 -and $p.B -lt 110 -and ($p.G - $p.R) -gt 55) {
        # require a neighbour to reject 1px noise / thin lines
        $q = $s.GetPixel($x + 2, $y)
        $r = $s.GetPixel($x, $y + 2)
        if ((($q.G -gt 130) -and ($q.R -lt 110)) -or (($r.G -gt 130) -and ($r.R -lt 110))) {
          $n++
          $d = [Math]::Sqrt(($x - $cx) * ($x - $cx) + ($y - $cy) * ($y - $cy))
          if ($d -lt $bd) { $bd = $d; $best = @{ x = $x; y = $y } }
        }
      }
    }
  }
  $g.Dispose(); $g2.Dispose(); $b.Dispose(); $s.Dispose()
  if (-not $best) { return $null }
  $dx = $best.x - $cx; $dy = $best.y - $cy
  $ang = [Math]::Atan2($dx, - $dy) * 180 / [Math]::PI
  if ($ang -lt 0) { $ang += 360 }
  @{ ang = [int]$ang; dist = [int]$bd; count = $n }
}

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class K { [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte scan, uint flags, int extra); }
"@ -ErrorAction SilentlyContinue

# CloudMoon maps hardware W/A/S/D + Space onto the Roblox mobile joystick (Show Hotkeys ON).
function KeyDown([byte]$vk) { [K]::keybd_event($vk, 0, 0, 0) }
function KeyUp([byte]$vk) { [K]::keybd_event($vk, 0, 2, 0) }
function Jump { KeyDown 0x20; Start-Sleep -m 90; KeyUp 0x20 }

function MoveAng([int]$ang, [int]$ms) {
  $o = [int]([Math]::Round((($ang % 360) / 45.0))) % 8
  $sets = @(@(0x57), @(0x57, 0x44), @(0x44), @(0x53, 0x44), @(0x53), @(0x53, 0x41), @(0x41), @(0x57, 0x41))
  $keys = $sets[$o]
  foreach ($k in $keys) { KeyDown $k }
  Start-Sleep -m $ms
  foreach ($k in $keys) { KeyUp $k }
  Start-Sleep -m 120
}

# Follow the in-game Guide: the green chevron trail points at the next thing you can buy.
# Averages the direction of every green pixel in an annulus around the character.
function GuideDir {
  $b = New-Object Drawing.Bitmap $global:SW, $global:SH
  $g = [Drawing.Graphics]::FromImage($b)
  $g.CopyFromScreen($global:SX, $global:SY, 0, 0, (New-Object Drawing.Size $global:SW, $global:SH))
  $w = 220; $h = [int]($global:SH * $w / $global:SW)
  $s = New-Object Drawing.Bitmap $w, $h
  $g2 = [Drawing.Graphics]::FromImage($s); $g2.DrawImage($b, 0, 0, $w, $h)
  $cx = ($global:CHX - $global:SX) * $w / $global:SW
  $cy = ($global:CHY - $global:SY) * $w / $global:SW
  $sx = 0.0; $sy = 0.0; $n = 0; $near = 0
  for ($y = 1; $y -lt $h - 1; $y++) {
    for ($x = 1; $x -lt $w - 1; $x++) {
      $p = $s.GetPixel($x, $y)
      if ($p.G -gt 120 -and $p.R -lt 120 -and $p.B -lt 120 -and ($p.G - $p.R) -gt 45) {
        $dx = $x - $cx; $dy = $y - $cy
        $d = [Math]::Sqrt($dx * $dx + $dy * $dy)
        if ($d -lt 6) { continue }
        if ($d -lt 16) { $near++ }
        # weight far pixels more: aim at the far end of the arrow trail, not our feet
        if ($d -le 90) { $sx += $dx / $d * $d; $sy += $dy / $d * $d; $n++ }
      }
    }
  }
  $g.Dispose(); $g2.Dispose(); $b.Dispose(); $s.Dispose()
  if ($n -lt 4) { return $null }
  $ang = [Math]::Atan2($sx, - $sy) * 180 / [Math]::PI
  if ($ang -lt 0) { $ang += 360 }
  @{ ang = [int]$ang; count = $n; near = $near }
}

function Guided([int]$Minutes = 10) {
  Act
  $end = (Get-Date).AddMinutes($Minutes)
  $i = 0; $miss = 0
  while ((Get-Date) -lt $end) {
    $i++
    if (Guard) { continue }
    $t = GuideDir
    if ($i % 6 -eq 0 -and (Drowned)) { Respawn; continue }
    if ($t) {
      MoveAng $t.ang 900
      if ($i % 5 -eq 0) { Jump }               # unstick from walls / steps
      if ($i % 8 -eq 0) { Write-Host ("{0} ang={1} px={2} near={3}" -f $i, $t.ang, $t.count, $t.near) }
    } else {
      $miss++
      Look 300
      if ($miss % 3 -eq 0) { MoveAng (Get-Random -Minimum 0 -Maximum 359) 1200 }
      if ($miss % 9 -eq 0) { Respawn }   # blind = camera clipped or wedged; reset
    }
  }
  Write-Host "guided done iters=$i miss=$miss"
}

# Serpentine sweep of the plot + micro-steps onto any pad right next to us.
try { Add-Type @"
using System;
using System.Runtime.InteropServices;
public class W5 { [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y); [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint dx, uint dy, int d, int e); }
"@ -ErrorAction SilentlyContinue } catch { }

function Wheel([int]$n) {
  [W5]::SetCursorPos(800, 400); Start-Sleep -m 150
  for ($i = 0; $i -lt [Math]::Abs($n); $i++) { [W5]::mouse_event(0x0800, 0, 0, (120 * [Math]::Sign($n)), 0); Start-Sleep -m 110 }
}

function Respawn {
  Act
  Click 346 124 200; Start-Sleep 3      # Roblox hamburger -> compact menu
  Click 365 430 200; Start-Sleep 3      # Respawn
  Click 681 509 200; Start-Sleep 10     # confirm
  Write-Host "respawned"
}

# Underwater = dark blue wash over the whole view (the ocean surrounds the plot).
function Drowned {
  foreach ($p in @(@(800, 250), @(700, 350))) {
    $c = GetPix $p[0] $p[1]
    $mx = [Math]::Max($c.R, [Math]::Max($c.G, $c.B))
    if (-not (($c.B - $c.R) -gt 35 -and $mx -lt 150)) { return $false }
  }
  $true
}

function Grind([int]$Minutes = 10) {
  Act
  Wheel -10          # zoom the camera out so pads/arrows are visible
  $end = (Get-Date).AddMinutes($Minutes)
  $legs = @(@(0, 2600), @(90, 700), @(180, 2600), @(90, 700))
  $i = 0; $pads = 0
  while ((Get-Date) -lt $end) {
    if (Guard) { continue }
    $t = GuideDir
    if ($t -and $t.near -gt 8) {
      MoveAng $t.ang 450; $pads++
    } else {
      $l = $legs[$i % 4]
      MoveAng $l[0] $l[1]
      $i++
    }
    if ($i % 6 -eq 0) { Jump }
    if ($i % 5 -eq 0 -and (Drowned)) { Respawn }
    if ($i % 20 -eq 0) { Write-Host ("leg=$i padsteps=$pads " + (Get-Date -Format HH:mm:ss)) }
  }
  Write-Host "grind done legs=$i padsteps=$pads"
}

function GetPix([int]$x, [int]$y) {
  $b = New-Object Drawing.Bitmap 1, 1
  $g = [Drawing.Graphics]::FromImage($b)
  $g.CopyFromScreen($x, $y, 0, 0, (New-Object Drawing.Size 1, 1))
  $p = $b.GetPixel(0, 0); $g.Dispose(); $b.Dispose(); $p
}

# Close blocking dialogs: Robux purchase prompt and "Join community" popup.
# Any blocking modal (Robux purchase, "need more Robux", join-community) shows a big blue button.
function IsModal {
  $blue = $false
  foreach ($p in @(@(800, 526), @(800, 511), @(733, 523))) {
    $c = GetPix $p[0] $p[1]
    if ($c.B -gt 170 -and $c.R -lt 110) { $blue = $true }
  }
  if (-not $blue) { return $false }
  # a real dialog also paints a big neutral dark-grey panel behind that button
  foreach ($p in @(@(700, 400), @(900, 400), @(700, 480), @(900, 480))) {
    $c = GetPix $p[0] $p[1]
    $mx = [Math]::Max($c.R, [Math]::Max($c.G, $c.B))
    $mn = [Math]::Min($c.R, [Math]::Min($c.G, $c.B))
    if ($mx -gt 95 -or ($mx - $mn) -gt 16) { return $false }
  }
  $true
}

# Close it by trying each known X / dismiss button in a safe order (never a Buy button first).
function Guard {
  if (-not (IsModal)) { return $false }
  # Roblox CoreGui purchase prompts only close with Escape; a 2nd Esc closes the
  # menu that Escape opens. Then walk off the pad or it re-triggers instantly.
  for ($k = 0; $k -lt 2; $k++) {
    $null = KeyDown 0x1B; Start-Sleep -m 90; $null = KeyUp 0x1B
    Start-Sleep -m 900
  }
  if (IsModal) {
    foreach ($c in @(@(1013, 216), @(617, 275), @(939, 329), @(800, 511), @(894, 524))) {
      Click $c[0] $c[1]
      Start-Sleep -m 700
      if (-not (IsModal)) { break }
    }
  }
  MoveAng (Get-Random -Minimum 0 -Maximum 359) 1400   # step off the pad
  Write-Host "prompt cleared"
  $true
}

function Bot([int]$Minutes = 5) {
  Act
  $end = (Get-Date).AddMinutes($Minutes)
  $i = 0; $hits = 0; $miss = 0
  while ((Get-Date) -lt $end) {
    $i++
    if (Guard) { continue }
    $t = GreenTarget
    if ($t) {
      $hits++
      $ms = if ($t.dist -gt 60) { 900 } elseif ($t.dist -gt 25) { 500 } else { 260 }
      Joy $t.ang $ms
      if ($i % 6 -eq 0) { Write-Host ("{0} ang={1} d={2} px={3}" -f $i, $t.ang, $t.dist, $t.count) }
      # every so often relocate so we don't camp one pad / the cash machine
      if ($i % 14 -eq 0) { Joy (Get-Random -Minimum 0 -Maximum 359) 1400; Joy (Get-Random -Minimum 0 -Maximum 359) 1400 }
    } else {
      $miss++
      Look 260
      if ($miss % 4 -eq 0) { Joy (Get-Random -Minimum 0 -Maximum 359) 900 }
    }
  }
  Write-Host ("bot done iters=$i hits=$hits miss=$miss")
}
Write-Host "bot loaded: GreenTarget Bot"
'@
. C:\l.ps1
. C:\bot.ps1
Act
Guided 6
Write-Host ("leg done " + (Get-Date -Format HH:mm:ss))
Add-Type -AssemblyName System.Drawing
$b=New-Object Drawing.Bitmap 1600,900
$g=[Drawing.Graphics]::FromImage($b); $g.CopyFromScreen(0,0,0,0,(New-Object Drawing.Size 1600,900))
$s=New-Object Drawing.Bitmap 1280,720
$g2=[Drawing.Graphics]::FromImage($s); $g2.DrawImage($b,0,0,1280,720)
$ms=New-Object IO.MemoryStream
$enc=[Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()|?{$_.MimeType -eq 'image/jpeg'}
$p=New-Object Drawing.Imaging.EncoderParameters 1
$p.Param[0]=New-Object Drawing.Imaging.EncoderParameter ([Drawing.Imaging.Encoder]::Quality),40
$s.Save($ms,$enc,$p)
"B64:"+[Convert]::ToBase64String($ms.ToArray())
