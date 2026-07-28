Set-Content -Encoding UTF8 C:\bot.ps1 -Value @'
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

function Bot([int]$Minutes = 5) {
  Act
  $end = (Get-Date).AddMinutes($Minutes)
  $i = 0; $hits = 0; $miss = 0
  while ((Get-Date) -lt $end) {
    $i++
    $t = GreenTarget
    if ($t) {
      $hits++
      $ms = if ($t.dist -gt 60) { 900 } elseif ($t.dist -gt 25) { 500 } else { 260 }
      Joy $t.ang $ms
      if ($i % 6 -eq 0) { Write-Host ("{0} ang={1} d={2} px={3}" -f $i, $t.ang, $t.dist, $t.count) }
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
. C:\bot.ps1
"SX=$($global:SX) SW=$($global:SW)"
$t = GreenTarget; if($t){ "target ang=$($t.ang) dist=$($t.dist) px=$($t.count)" } else { "no green" }
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
