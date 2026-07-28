'TAG:T1785258347'
. C:\l.ps1
function Key([byte]$vk,[int]$hold=60){ [K]::keybd_event($vk,0,0,0); Start-Sleep -m $hold; [K]::keybd_event($vk,0,2,0); Start-Sleep -m 250 }
Act
Key 0x1B          # close the Roblox menu (Resume)
Start-Sleep -m 800
Joy 180 1400      # walk backwards off the weapon pad
Start-Sleep -m 400
Joy 180 1200
"walked off pad"
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
