CClick 799 549; Start-Sleep 3
Click 875 116; Start-Sleep 4
Click 572 321; Start-Sleep 6
Click 745 339; Start-Sleep 55
"joining"
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
