. C:\l.ps1
. C:\bot.ps1
Add-Type -AssemblyName System.Windows.Forms
Act
$null = Click 1405 126
Start-Sleep 4
$null = Click 796 446
Start-Sleep 2
foreach($i in 1..2){ $null=KeyDown 0x28; Start-Sleep -m 80; $null=KeyUp 0x28; Start-Sleep -m 250 }
$null=KeyDown 0x0D; Start-Sleep -m 80; $null=KeyUp 0x0D
Start-Sleep 2
$null = Click 852 588 150
Start-Sleep 3
$null = Click 796 450
Start-Sleep 1
[System.Windows.Forms.SendKeys]::SendWait("somanyalts30@gmail.com")
Start-Sleep 1
$null = Click 796 519
Start-Sleep 1
[System.Windows.Forms.SendKeys]::SendWait("Azerty060809*")
Start-Sleep 1
$null = Click 796 588 150
Start-Sleep 8
$null = Click 1446 371
Start-Sleep 2
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
