# [ NOTE ] https://stackoverflow.com/questions/10365394/change-windows-font-size-dpi-in-powershell
# [ NOTE ] https://www.tenforums.com/tutorials/5990-change-dpi-scaling-level-displays-windows-10-a.html
$val = Get-ItemProperty -Path 'HKLM:/Software/Microsoft/Windows NT/CurrentVersion/FontDPI'  -Name "LogPixels"
if($val.LogPixels -ne 96)
{
    Write-Host 'Change to 100% / 96 dpi'
    Set-ItemProperty -Path 'HKLM:/Software/Microsoft/Windows NT/CurrentVersion/FontDPI' -Name LogPixels -Value 96
} else {
    #Write-Host 'Change to 150% / 144 dpi'
    Write-Host 'Change to 200% / 192 dpi'
    Set-ItemProperty -Path 'HKLM:/Software/Microsoft/Windows NT/CurrentVersion/FontDPI' -Name LogPixels -Value 192
}
