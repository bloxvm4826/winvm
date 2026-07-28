'TAG:T1785258694'
(Get-Content C:\play2.log -Tail 5) -join " / "
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
