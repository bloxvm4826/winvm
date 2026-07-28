Add-Type @"
using System;
using System.Runtime.InteropServices;
public class K { [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte scan, uint flags, int extra); }
"@ -EA SilentlyContinue
function Hold([byte]$vk,[int]$ms){ [K]::keybd_event($vk,0,0,0); Start-Sleep -m $ms; [K]::keybd_event($vk,0,2,0); Start-Sleep -m 200 }
Act
Hold 0x57 1500
Hold 0x41 1000
"pressed W and A"
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
