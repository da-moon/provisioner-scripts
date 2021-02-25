# this scripts turns off visual effects to adjust for best performance
# turn off transparency
Reg Add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f
# https://www.lifewire.com/adjust-visual-effects-to-improve-speed-3506867
$path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
try {
  $s = (Get-ItemProperty -ErrorAction stop -Name visualfxsetting -Path $path).visualfxsetting
  if ($s -ne 2) {
  Set-ItemProperty -Path $path -Name 'VisualFXSetting' -Value 2
  }
}
catch {
  New-ItemProperty -Path $path -Name 'VisualFXSetting' -Value 2 -PropertyType 'DWORD'
}

