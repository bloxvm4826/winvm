iwr https://raw.githubusercontent.com/bloxvm4826/winvm/main/lib.ps1 -o C:\l.ps1
. C:\l.ps1
Add-Type -AssemblyName System.Windows.Forms
$s=[System.Windows.Forms.Screen]::PrimaryScreen.Bounds
"screen: $($s.Width)x$($s.Height)"
$h=Hwnd; "chrome hwnd: $h  zoomed:" + [W]::IsZoomed($h)
