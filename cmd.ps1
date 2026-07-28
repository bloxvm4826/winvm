'TAG:T1785259632'
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*play3.ps1*" } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -EA 0 }
Start-Sleep -m 600
. C:\l.ps1
function Key([byte]$vk,[int]$hold=60){ [K]::keybd_event($vk,0,0,0); Start-Sleep -m $hold; [K]::keybd_event($vk,0,2,0); Start-Sleep -m 250 }
Act
# full respawn to get out of the water, then close every overlay
Click 346 124 250; Start-Sleep -m 700
Click 365 430 250; Start-Sleep -m 900
Click 681 476 250; Start-Sleep -m 4500
Click 346 124 250; Start-Sleep -m 900
"sorties done: " + ((Get-Content C:\play3.log | Select-String "sortie").Count)
Add-Type -AssemblyName System.Windows.Forms,System.Drawing
$b=[System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp=New-Object Drawing.Bitmap $b.Width,$b.Height
$g=[Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($b.Location,[Drawing.Point]::Empty,$b.Size)
$sm=New-Object Drawing.Bitmap 1280,720
$g2=[Drawing.Graphics]::FromImage($sm)
$g2.DrawImage($bmp,0,0,1280,720)
$ms=New-Object IO.MemoryStream
$enc=[Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()|Where-Object {$_.MimeType -eq 'image/jpeg'}
$p=New-Object Drawing.Imaging.EncoderParameters 1
$p.Param[0]=New-Object Drawing.Imaging.EncoderParameter ([Drawing.Imaging.Encoder]::Quality),50
$sm.Save($ms,$enc,$p)
"B64:"+[Convert]::ToBase64String($ms.ToArray())
