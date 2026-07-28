'TAG:T1785258317'
. C:\l.ps1
if (-not ("K" -as [type])) {
  Add-Type "using System;using System.Runtime.InteropServices;public class K { [DllImport(\"user32.dll\")] public static extern void keybd_event(byte v, byte s, uint f, int e); }"
}
function Key([byte]$vk,[int]$hold=60){ [K]::keybd_event($vk,0,0,0); Start-Sleep -m $hold; [K]::keybd_event($vk,0,2,0); Start-Sleep -m 250 }
$a = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*auto.ps1*" }
"autopilot still running: " + $(if($a){($a.ProcessId -join ",")}else{"NO - stopped"})
Act
Key 0x1B
Start-Sleep -m 1000
"esc sent"
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
