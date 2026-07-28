Add-Type @"
using System;
using System.Runtime.InteropServices;
public class W2 {
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint dx, uint dy, int d, int e);
}
"@ -EA SilentlyContinue
function Scroll([int]$x,[int]$y,[int]$notches){ Act; [W2]::SetCursorPos($x,$y); Start-Sleep -m 200; for($i=0;$i -lt [Math]::Abs($notches);$i++){ [W2]::mouse_event(0x0800,0,0,(120*[Math]::Sign($notches)),0); Start-Sleep -m 120 } }
Scroll 800 450 -5
Start-Sleep 2
"scrolled"
