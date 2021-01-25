# this script install chrome and chrome RDP
 & { `
  $chrome_installer_url="https://dl.google.com/chrome/install/latest/chrome_installer.exe"; `
  $P=$env:TEMP+"\chrome_installer.exe"; `
  $start_time = Get-Date; `
  Set-ExecutionPolicy Bypass -Scope Process -Force; `
  [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"; `
  Invoke-WebRequest "$chrome_installer_url" -OutFile $P; `
  Start-Process -FilePath $P -Args '/install' -Verb RunAs -Wait; `
  Remove-Item $P; `
  Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"; `
 }

 & { `
  $chrome_rdp_installer_url="https://dl.google.com/edgedl/chrome-remote-desktop/chromeremotedesktophost.msi"; `
  $P=$env:TEMP+"\chromeremotedesktophost.msi"; `
  $start_time = Get-Date; `
  Set-ExecutionPolicy Bypass -Scope Process -Force; `
  [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"; `
  Invoke-WebRequest "$chrome_rdp_installer_url" -OutFile $P; `
  Start-Process $P -Wait; `
  Remove-Item $P; `
  Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"; `
 }

