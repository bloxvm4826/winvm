. C:\bot.ps1
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class W4 { [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y); [DllImport("user32.dll")] public static extern void mouse_event(uint f,uint dx,uint dy,int d,int e); }
"@ -EA SilentlyContinue
function Wheel([int]$n){ [W4]::SetCursorPos(800,400); Start-Sleep -m 200; for($i=0;$i -lt [Math]::Abs($n);$i++){ [W4]::mouse_event(0x0800,0,0,(120*[Math]::Sign($n)),0); Start-Sleep -m 120 } }
Act
Wheel -8
Start-Sleep 2
"zoomed out"
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
