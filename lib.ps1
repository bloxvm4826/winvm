# War Tycoon / CloudMoon control library - runs ON the VM (1600x900 desktop).
# Load with:  iwr https://raw.githubusercontent.com/bloxvm4826/winvm/main/lib.ps1 -o l.ps1; . .\l.ps1

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class W {
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint dx, uint dy, uint d, int e);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll")] public static extern bool IsZoomed(IntPtr h);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  public const uint DOWN = 0x0002, UP = 0x0004;
}
"@ -ErrorAction SilentlyContinue

function Hwnd {
  (Get-Process chrome -EA 0 | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1).MainWindowHandle
}

# Focus Chrome WITHOUT changing its maximized state (SW_RESTORE would un-maximize it).
function Act {
  $h = Hwnd
  if (-not $h) { return }
  if ([W]::IsIconic($h)) { [W]::ShowWindow($h, 3) | Out-Null; Start-Sleep -Milliseconds 400 }
  [W]::SetForegroundWindow($h) | Out-Null
  Start-Sleep -Milliseconds 350
}

function Maxi { $h = Hwnd; if ($h) { [W]::ShowWindow($h, 3) | Out-Null; Start-Sleep -Milliseconds 600 } }

function Click([int]$x, [int]$y, [int]$hold = 90) {
  [W]::SetCursorPos($x, $y); Start-Sleep -Milliseconds 120
  [W]::mouse_event([W]::DOWN, 0, 0, 0, 0); Start-Sleep -Milliseconds $hold
  [W]::mouse_event([W]::UP, 0, 0, 0, 0);   Start-Sleep -Milliseconds 200
}

function CClick([int]$x, [int]$y, [int]$hold = 90) { Act; Click $x $y $hold }

function Drag([int]$x1, [int]$y1, [int]$x2, [int]$y2, [int]$hold = 300, [int]$steps = 22) {
  [W]::SetCursorPos($x1, $y1); Start-Sleep -Milliseconds 150
  [W]::mouse_event([W]::DOWN, 0, 0, 0, 0); Start-Sleep -Milliseconds 280
  for ($i = 1; $i -le $steps; $i++) {
    [W]::SetCursorPos([int]($x1 + ($x2 - $x1) * $i / $steps), [int]($y1 + ($y2 - $y1) * $i / $steps))
    Start-Sleep -Milliseconds 28
  }
  Start-Sleep -Milliseconds $hold
  [W]::mouse_event([W]::UP, 0, 0, 0, 0); Start-Sleep -Milliseconds 250
}

# --- game geometry (REMOTE 1600x900 desktop coords) ---
$global:JOY = @{ x = 380; y = 585; r = 62 }
$global:CAM = @{ x = 965; y = 200 }

function Joy([double]$deg, [int]$ms) {
  $rad = $deg * [Math]::PI / 180.0
  $tx = [int]($global:JOY.x + [Math]::Sin($rad) * $global:JOY.r)
  $ty = [int]($global:JOY.y - [Math]::Cos($rad) * $global:JOY.r)
  [W]::SetCursorPos($global:JOY.x, $global:JOY.y); Start-Sleep -Milliseconds 80
  [W]::mouse_event([W]::DOWN, 0, 0, 0, 0); Start-Sleep -Milliseconds 110
  for ($i = 1; $i -le 6; $i++) {
    [W]::SetCursorPos([int]($global:JOY.x + ($tx - $global:JOY.x) * $i / 6), [int]($global:JOY.y + ($ty - $global:JOY.y) * $i / 6))
    Start-Sleep -Milliseconds 22
  }
  Start-Sleep -Milliseconds $ms
  [W]::mouse_event([W]::UP, 0, 0, 0, 0); Start-Sleep -Milliseconds 200
}

function Look([int]$dx, [int]$dy = 0) { Drag $global:CAM.x $global:CAM.y ($global:CAM.x + $dx) ($global:CAM.y + $dy) 200 25 }

# Continuously walk a circuit so every affordable buy-pad on the plot gets stepped on.
# Constant input also stops CloudMoon's inactivity disconnect.
function Play([int]$Minutes = 20, [int]$LegMs = 2400) {
  Act
  $end = (Get-Date).AddMinutes($Minutes)
  $dirs = @(0, 45, 90, 135, 180, 225, 270, 315)
  $i = 0; $lap = 0
  Write-Host "play until $end"
  while ((Get-Date) -lt $end) {
    $len = if ($lap % 2 -eq 0) { $LegMs } else { [int]($LegMs * 0.55) }
    Joy $dirs[$i % 8] $len
    $i++
    if ($i % 8 -eq 0) { $lap++; Write-Host ("lap {0} {1:HH:mm:ss}" -f $lap, (Get-Date)) }
  }
  Write-Host "play done"
}

Write-Host "lib loaded: Act Maxi Click CClick Drag Joy Look Play"
