'TAG:T1785258813'
. C:\l.ps1
Act
Click 346 124 250        # close the compact menu left open
Start-Sleep -m 800
$t=[int](Get-Date -UFormat %s)
irm "https://raw.githubusercontent.com/bloxvm4826/winvm/main/play2.ps1?t=$t" -OutFile C:\play2.ps1
Remove-Item C:\play2.log -EA 0
Start-Process powershell -ArgumentList "-ExecutionPolicy","Bypass","-WindowStyle","Hidden","-File","C:\play2.ps1","-Minutes","60" -WindowStyle Hidden
Start-Sleep -m 3000
"relaunched"
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
