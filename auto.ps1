. C:\l.ps1
. C:\bot.ps1
$end = Get-Date "2026-07-28 21:10:00"
$n = 0
Add-Content C:\auto.log ("START " + (Get-Date -Format HH:mm:ss))
while ((Get-Date) -lt $end) {
  $n++
  try {
    Act
    if (Drowned) { Respawn }
    Guided 4
    Respawn                      # reset to base spawn so we never stay lost
  } catch { Start-Sleep 5 }
  Add-Content C:\auto.log ("loop $n " + (Get-Date -Format HH:mm:ss))
}
Add-Content C:\auto.log ("END " + (Get-Date -Format HH:mm:ss))
