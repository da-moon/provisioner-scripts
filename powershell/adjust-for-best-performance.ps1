#Requires -Version 5
# Check OS and ensure we are running on Windows
if (-Not ($Env:OS -eq "Windows_NT")) {
  Write-Host "Error: This script only supports Windows machines. Exiting..."
  exit 1
}
# powershell -executionpolicy bypass -File adjust-for-best-performance.ps1

function abort($msg, [int] $exit_code=1) { 
  write-host $msg -f red
  exit $exit_code
}
function error($msg) { 
  write-host "[ERROR] $msg" -f darkred 
}
function warn($msg) {
  write-host "[WARN]  $msg" -f darkyellow 
}
function info($msg) {  
  write-host "[INFO]  $msg" -f darkcyan 
}
function debug($msg) {  
  write-host "[DEBUG]  $msg" -f darkgray 
}
function success($msg) { 
  write-host  "[DONE] $msg" -f darkgreen 
}
function pwd($path) {
  "$($myinvocation.psscriptroot)\$path" 
}
$optional_features_to_remove = @(
  'Printing-PrintToPDFServices-Features',
  'Printing-XPSServices-Features',
  'Xps-Foundation-Xps-Viewer',
  'WorkFolders-Client',
  'MediaPlayback',
  'SMB1Protocol',
  'WCF-Services45',
  'MSRDC-Infrastructure',
  'Internet-Explorer-Optional-amd64'
)
$tweaks = @(
"DisableTelemetry",
  "DisableWiFiSense",             
  "DisableSmartScreen",           
  "DisableWebSearch",             
  "DisableAppSuggestions",        
  "DisableBackgroundApps",        
  "DisableLockScreenSpotlight",   
  "DisableLocationTracking",      
  "DisableMapUpdates",            
  "DisableFeedback",              
  "DisableAdvertisingID",
  "DisableCortana",        
  "DisableErrorReporting", 
  "DisableAutoLogger",
  "DisableDiagTrack",
  "DisableWAPPush",               
  "RemoveUnneededComponents",
  "SetUACLow",                    
  "DisableAdminShares",         
  "EnableCtrldFolderAccess",     
  "DisableDefender",            
  "DisableDefenderCloud",       
  "DisableUpdateMSRT",          
  "DisableUpdateDriver",       
  "DisableUpdateRestart",         
  "DisableSharedExperiences",     
  "DisableRemoteAssistance",      
  "EnableRemoteDesktop",          
  "DisableAutoplay",              
  "DisableAutorun",               
  "DisableStorageSense",          
  "DisableDefragmentation",       
  "DisableSuperfetch",            
  "DisableIndexing",              
  "DisableHibernation",           
  "DisableFastStartup",           
  "SetBIOSTimeLocal",             
  "DisableLockScreen",            
  "DisableLockScreenRS1",         
  "ShowShutdownOnLockScreen",     
  "DisableStickyKeys",            
  "ShowTaskManagerDetails"        
  "ShowFileOperationsDetails",    
  "DisableFileDeleteConfirm",  
  "ShowTaskbarSearchBox",         
  "ShowTaskView",                 
  "ShowLargeTaskbarIcons",        
  "HideTaskbarTitles",            
  "HideTaskbarPeopleIcon",        
  "ShowTrayIcons",                
  "ShowKnownExtensions",          
  "ShowHiddenFiles",              
  "HideSyncNotifications"         
  "HideRecentShortcuts",          
  "SetExplorerThisPC",            
  "ShowThisPCOnDesktop",          
  "ShowUserFolderOnDesktop",   
  "Hide3DObjectsFromThisPC",    
  "SetVisualFXPerformance",       
  "DisableThumbnails",            
  "DisableThumbsDB",              
  "EnableNumlock",                
  "DisableOneDrive",             
  "UninstallOneDrive",           
  "UninstallBloat",              
  "DisableAdobeFlash",        
  "UninstallMediaPlayer",         
  "UninstallWorkFolders",         
  "AddPhotoViewerOpenWith",       
  "DisableSearchAppInStore",      
  "DisableNewAppPrompt",          
  "SetDEPOptOut",                 
  "DisableExtraServices",
  "DeleteTempFiles",
  "CleanWinSXS",
  "DownloadShutup10",
  "EnableWindowsSearch",          
  "DisableCompatibilityAppraiser",
  "EnableBigDesktopIcons",
  "DisableGPDWinServices"
)
$microsoft_apps_to_remove = @(
  "3DBuilder",
  "BingFinance",
  "BingNews",
  "BingSports",
  "BingWeather",
  "Getstarted",
  "MicrosoftOfficeHub",
  "MicrosoftSolitaireCollection",
  "SkypeApp",
  "WindowsCamera",
  "windowscommunicationsapps",
  "WindowsMaps",
  "WindowsPhone",
  "ZuneMusic",
  "ZuneVideo",
  "AppConnector",
  "ConnectivityStore",
  "Office.Sway",
  "Messaging",
  "CommsPhone",
  "OneConnect",
  "WindowsFeedbackHub",
  "MinecraftUWP",
  "MicrosoftPowerBIForWindows",
  "NetworkSpeedTest",
  "Microsoft3DViewer",
  "Print3D",
  "XboxApp",
  "XboxIdentityProvider",
  "XboxSpeechToTextOverlay",
  "XboxGameOverlay",
  "Xbox.TCUI"
)
$thirdparty_apps_to_remove= @(
  "9E2F88E3.Twitter",
  "king.com.CandyCrushSodaSaga",
  "4DF9E0F8.Netflix",
  "Drawboard.DrawboardPDF",
  "D52A8D61.FarmVille2CountryEscape",
  "GAMELOFTSA.Asphalt8Airborne",
  "flaregamesGmbH.RoyalRevolt2",
  "AdobeSystemsIncorporated.AdobePhotoshopExpress",
  "ActiproSoftwareLLC.562882FEEB491",
  "D5EA27B7.Duolingo-LearnLanguagesforFree",
  "Facebook.Facebook",
  "46928bounde.EclipseManager",
  "A278AB0D.MarchofEmpires",
  "KeeperSecurityInc.Keeper",
  "king.com.BubbleWitch3Saga",
  "89006A2E.AutodeskSketchBook",
  "CAF9E577.Plex"
)
$services_to_disable = @(
  "diagnosticshub.standardcollector.service",
  "MapsBroker",
  "NetTcpPortSharing",
  "TrkWks",
  "WbioSrvc",
  "WMPNetworkSvc",
  "AppVClient",
  "RemoteRegistry",
  "CDPSvc",
  "shpamsvc",
  "SCardSvr",
  "UevAgentService",
  "PeerDistSvc",
  "lfsvc",
  "HvHost",
  "vmickvpexchange",
  "vmicguestinterface",
  "vmicshutdown",
  "vmicheartbeat",
  "vmicvmsession",
  "vmicrdv",
  "vmictimesync",
  "vmicvss",
  "irmon",
  "SharedAccess",
  "SmsRouter",
  "CscService",
  "SEMgrSvc",
  "PhoneSvc",
  "RpcLocator",
  "RetailDemo",
  "SensorDataService",
  "SensrSvc",
  "SensorService",
  "ScDeviceEnum",
  "SCPolicySvc",
  "SNMPTRAP",
  "WFDSConSvc",
  "FrameServer",
  "wisvc",
  "icssvc",
  "WwanSvc"
)
function Confirm-Aria2 {
  if ((Get-Command "aria2c" -ErrorAction SilentlyContinue) -eq $null) 
  { 
      warn "Unable to find aria2c in your PATH"
      info "downloading aria2 with scoop"
      scoop install aria2
  }
}
function aria2_dl($url,$dir,$file) {
  Confirm-Aria2
  try {
      info "Downloading $file from $url and storing it in $dir"
      aria2c -k 1M -c -j16 -x16 --dir="$dir" --out="$file" "$url"
      success "Downloading $file from $url and storing it in $dir"
  }
  catch
  {
      warn "could not downloading $file from $url"
  }
}
function dl($url,$to) {
  $wc = New-Object Net.Webclient
  $wc.downloadFile($url,$to)
}
Function DisableOneDrive {
info "Disabling OneDrive..."
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" DWord 1
success "Disabling OneDrive..."
}
function Safe-Set-ItemProperty($Path,$Name,$Type,$Value) {
  try {
      debug "setting path $Path with name $Name , type $Type and value $Value"
      Set-ItemProperty -Path "$path" -Name "$Name" -Type $Type -Value $Value -ErrorAction Stop | Out-Null
  }
  catch {
      warn "could not set path $Path with name $Name , type $Type and value $Value"
  }
}
function Safe-Remove-ItemProperty($Path,$Name,$Type,$Value) {
  try {
      debug "removing item property $Name of $Path"
      Remove-ItemProperty -Path "$path" -Name "$Name" -ErrorAction Stop | Out-Null
  }
  catch {
      warn "could not removing item property $Name of $Path"
  }
}
function Safe-Uninstall($app) {
  try {
      info "uninstalling $app"
      Get-AppxPackage -all "$app" | Remove-AppxPackage -AllUsers
      success "uninstalling $app"
  }
  catch {
      warn "uninstalling $app failed. possible cause is that $app was not installed at the time of executing $script_name script."
  }
}
function Create-Path-If-Not-Exists($Path) {
  try {
      debug "checking if path $Path exists"
      If (!(Test-Path "$Path")) {
          debug "$Path does not exists. creating ..."
          New-Item -Path "$Path" -Force -ErrorAction Stop | Out-Null
      }
  }
  catch {
      warn "could not create path $Path"
  }
}
Function DisableTelemetry {
  info "Disabling Telemetry..."
  $paths=@(
      "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection",
      "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection",
      "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
  )
  foreach($path in $paths) {
      Safe-Set-ItemProperty "$path" "AllowTelemetry" DWord 0
  }
  success "Disabling Telemetry..."
}
Function DisableWiFiSense {
info "Disabling Wi-Fi Sense..."
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting"
  $paths=@(
      "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting",
      "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots"
  )
  foreach($path in $paths) {
      Safe-Set-ItemProperty  "$path" "Value" DWord 0
  }
success "Disabling Wi-Fi Sense..."
}
Function DisableSmartScreen {
  info "Disabling SmartScreen Filter..."
  $path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
  Safe-Set-ItemProperty "$path" "SmartScreenEnabled" String "Off"
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost"
  Safe-Set-ItemProperty "$path" "EnableWebContentEvaluation" DWord 0
$edge = (Get-AppxPackage -AllUsers "Microsoft.MicrosoftEdge").PackageFamilyName
  $path="HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\PhishingFilter"
  Create-Path-If-Not-Exists "$path"
  $names=@(
      "EnabledV9" , 
      "PreventOverride"
  )
  foreach($name in $names) {
      Safe-Set-ItemProperty "$path" "$name" DWord 0
  }
  success "Disabling SmartScreen Filter..."
}
Function DisableWebSearch {
  info "Disabling Bing Search in Start Menu..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
  Safe-Set-ItemProperty "$path" "BingSearchEnabled" DWord 0
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch" DWord 1
  success "Disabling Bing Search in Start Menu..."
}
Function DisableBackgroundApps {
  info "Disabling Background application access..."
  $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
  Get-ChildItem "$path" | ForEach-Object {
      Safe-Set-ItemProperty $_.PsPath  "Disabled" DWord 1
      Safe-Set-ItemProperty $_.PsPath  "DisabledByUser" DWord 1
  }
  success "Disabling Background application access..."
}
Function DisableLockScreenSpotlight {
  info "Disabling Lock screen spotlight..."
  $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
  $names=@(
      "RotatingLockScreenEnabled" , 
      "RotatingLockScreenOverlayEnabled",
      "SubscribedContent-338387Enabled"
  )
  foreach($name in $names) {
      Safe-Set-ItemProperty "$path" "$name" DWord 0
  }
  success "Disabling Lock screen spotlight..."
}
Function DisableLocationTracking {
  info "Disabling Location Tracking..."
  $paths = @{
      'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}' = 'SensorPermissionState'
      'HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration' = 'Status'
  }
  $paths.GetEnumerator() | ForEach-Object {
      $path=$_.Key
      Safe-Set-ItemProperty "$path"  $_.Value DWord 0
  }
  success "Disabling Location Tracking..."
}
Function DisableMapUpdates {
  info "Disabling automatic Maps updates..."
  $path="HKLM:\SYSTEM\Maps"
  Safe-Set-ItemProperty "$path" "AutoUpdateEnabled" DWord 0
  success "Disabling automatic Maps updates..."
}
Function DisableFeedback {
info "Disabling Feedback..."
  Create-Path-If-Not-Exists "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"
  Safe-Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" DWord 0
success "Disabling Feedback..."
}
Function DisableAdvertisingID {
  info "Disabling Advertising ID..."
  $paths = @{
      'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' = 'Enabled'
      'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy' = 'TailoredExperiencesWithDiagnosticDataEnabled'
  }
  $paths.GetEnumerator() | ForEach-Object {
      $path=$_.Key
      Create-Path-If-Not-Exists "$path"
      Safe-Set-ItemProperty "$path"  $_.Value DWord 0
  }
success "Disabling Advertising ID..."
}
Function DisableCortana {
  info "Disabling Cortana..."
  Create-Path-If-Not-Exists "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
  Safe-Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" DWord 0
  Create-Path-If-Not-Exists "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
  Safe-Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\InputPersonalization" "RestrictImplicitTextCollection" DWord 1
  Safe-Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\InputPersonalization" "RestrictImplicitInkCollection" DWord 1
  Create-Path-If-Not-Exists "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"	
  Safe-Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" "HarvestContacts" DWord 0
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" DWord 0
  success "Disabling Cortana..."
}
Function DisableErrorReporting {
  info "Disabling Error reporting..."
  $path="HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting"
  Safe-Set-ItemProperty "$path" "Disabled" DWord 1
  success "Disabling Error reporting..."
}
Function DisableAutoLogger {
info "Removing AutoLogger file and restricting directory..."
$autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
# If (Test-Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl") {
      Remove-Item  -Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl" -ErrorAction SilentlyContinue
# }
icacls $autoLoggerDir /deny SYSTEM:`(OI`)`(CI`)F | Out-Null
success "Removing AutoLogger file and restricting directory..."
}
Function DisableDiagTrack {
info "Stopping and disabling Diagnostics Tracking Service..."
Stop-Service "DiagTrack" -WarningAction SilentlyContinue
Set-Service "DiagTrack" -StartupType Disabled
success "Stopping and disabling Diagnostics Tracking Service..."
}
Function DisableWAPPush {
info "Stopping and disabling WAP Push Service..."
Stop-Service "dmwappushservice" -WarningAction SilentlyContinue
Set-Service "dmwappushservice" -StartupType Disabled
success "Stopping and disabling WAP Push Service..."
}
# Disable Application suggestions and automatic installation
Function DisableAppSuggestions {
  info "Disabling Application suggestions..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
  $names=@(
      "ContentDeliveryAllowed",
      "OemPreInstalledAppsEnabled" ,
      "PreInstalledAppsEnabled",
      "PreInstalledAppsEverEnabled" ,
      "SilentInstalledAppsEnabled" ,
      "SubscribedContent-338389Enabled" ,
      "SystemPaneSuggestionsEnabled" ,
      "SubscribedContent-338388Enabled" 
  )
  foreach($name in $names) {
      Safe-Set-ItemProperty "$path" "$name" DWord 0
  }
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" DWord 1
}
Function UninstallOneDrive {
info "Uninstalling OneDrive..."
Stop-Process -Name OneDrive -ErrorAction SilentlyContinue
Start-Sleep -s 3
$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
If (!(Test-Path $onedrive)) {
  $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
  }
Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
Start-Sleep -s 3
Stop-Process -Name explorer -ErrorAction SilentlyContinue
Start-Sleep -s 3
Remove-Item "$env:USERPROFILE\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse -ErrorAction SilentlyContinue
If (!(Test-Path "HKCR:")) {
  New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
}
Remove-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
success "Uninstalling OneDrive..."
}
Function UninstallBloat {
  info "Removing Windows Bloatware ..."
  info "Uninstalling default Microsoft applications..."
  foreach($app in $microsoft_apps_to_remove) {
      Safe-Uninstall "Microsoft.$app"
  }
  success "Uninstalling default Microsoft applications..."

  info "Uninstalling default third party applications..."
  foreach($app in $thirdparty_apps_to_remove) {
      Safe-Uninstall "$app"
  }
  success "Uninstalling default third party applications..."
  info "Disabling Xbox ..."
  # xbox ....
  Safe-Set-ItemProperty "HKCU:\System\GameConfigStore" "GameDVR_Enabled" DWord 0
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" DWord 0
  success "Disabling Xbox ..."
  success "Removing Windows Bloatware ..."
}
Function UninstallWindowsStore {
info "Uninstalling Windows Store..."
Get-AppxPackage "Microsoft.DesktopAppInstaller" | Remove-AppxPackage
Get-AppxPackage "Microsoft.WindowsStore" | Remove-AppxPackage
success "Uninstalling Windows Store..."
}
Function InstallWindowsStore {
info "Installing Windows Store..."
Get-AppxPackage -AllUsers "Microsoft.DesktopAppInstaller" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
Get-AppxPackage -AllUsers "Microsoft.WindowsStore" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
success "Installing Windows Store..."
}
Function DisableAdobeFlash {
info "Disabling built-in Adobe Flash in IE and Edge..."
  Create-Path-If-Not-Exists "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Addons"
  Safe-Set-ItemProperty "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Addons" "FlashPlayerEnabled" DWord 0
  Create-Path-If-Not-Exists "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\{D27CDB6E-AE6D-11CF-96B8-444553540000}"
  Safe-Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\{D27CDB6E-AE6D-11CF-96B8-444553540000}" "Flags" DWord 1
success "Disabling built-in Adobe Flash in IE and Edge..."
}
Function UninstallMediaPlayer {
info "Uninstalling Windows Media Player..."
Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null
success "Uninstalling Windows Media Player..."
}
# Install Windows Media Player
Function InstallMediaPlayer {
info "Installing Windows Media Player..."
Enable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null
success "Installing Windows Media Player..."
}
Function UninstallWorkFolders {
info "Uninstalling Work Folders Client..."
Disable-WindowsOptionalFeature -Online -FeatureName "WorkFolders-Client" -NoRestart -WarningAction SilentlyContinue | Out-Null
success "Uninstalling Work Folders Client..."
}
Function AddPhotoViewerOpenWith {
info "Adding Photo Viewer to `"Open with...`""
If (!(Test-Path "HKCR:")) {
  New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
}
New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Force | Out-Null
New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Force | Out-Null
  Safe-Set-ItemProperty "HKCR:\Applications\photoviewer.dll\shell\open" "MuiVerb" String "@photoviewer.dll,-3043"
  Safe-Set-ItemProperty "HKCR:\Applications\photoviewer.dll\shell\open\command" "(Default)"  ExpandString   "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
  Safe-Set-ItemProperty "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" "Clsid"  String "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
info "Adding Photo Viewer to `"Open with...`""
}
Function DisableSearchAppInStore {
info "Disabling search for app in store for unknown extensions..."
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoUseStoreOpenWith" DWord 1
success "Disabling search for app in store for unknown extensions..."
}
Function EnableSearchAppInStore {
info "Enabling search for app in store for unknown extensions..."
Safe-Remove-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoUseStoreOpenWith"
success "Enabling search for app in store for unknown extensions..."
}
Function DisableNewAppPrompt {
info "Disabling 'How do you want to open this file?' prompt..."
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoNewAppAlert" DWord 1
success "Disabling 'How do you want to open this file?' prompt..."
}
Function EnableNewAppPrompt {
info "Enabling 'How do you want to open this file?' prompt..."
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoNewAppAlert" -ErrorAction SilentlyContinue
success "Enabling 'How do you want to open this file?' prompt..."
}
Function DeleteTempFiles {
  info "Cleaning up temporary files..."
  $tempfolders = @("C:\Windows\Temp\*", "C:\Windows\Prefetch\*", "C:\Documents and Settings\*\Local Settings\temp\*", "C:\Users\*\Appdata\Local\Temp\*")
  Remove-Item $tempfolders -force -recurse -ErrorAction SilentlyContinue 2>&1 | Out-Null
  success "Cleaning up temporary files..."
}
# Clean WinSXS folder (WARNING: this takes a while!)
Function CleanWinSXS {
  info "Cleaning WinSXS folder, this may take a while, please wait..."
  Dism.exe /online /Cleanup-Image /StartComponentCleanup
  success "Cleaning WinSXS folder, this may take a while, please wait..."
}
Function DownloadShutup10 {
  info "Downloading Shutup10 & putting it on C drive..."
  $url = "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe"
  $dir=pwd
  $file="Shutup10.exe"
  aria2_dl "$url" "$dir" "$file"
  success "Downloading Shutup10 & putting it on C drive..."
}
Function DisableWindowsSearch {
info "Stopping and disabling Windows Search Service..."
Stop-Service "WSearch" -WarningAction SilentlyContinue
Set-Service "WSearch" -StartupType Disabled
success "Stopping and disabling Windows Search Service..."
}
Function EnableWindowsSearch {
info "Enabling and starting Windows Search Service..."
Set-Service "WSearch" -StartupType Automatic
Start-Service "WSearch" -WarningAction SilentlyContinue
success "Enabling and starting Windows Search Service..."
}
Function DisableCompatibilityAppraiser {
info "Stopping and disabling Microsoft Compatibility Appraiser..."
info "Disable compattelrunner.exe launched by scheduled tasks..."
  'Microsoft Compatibility Appraiser',
  'ProgramDataUpdater' | ForEach-Object {
      Get-ScheduledTask -TaskName $_ -TaskPath '\Microsoft\Windows\Application Experience\' |
      Disable-ScheduledTask | Out-Null
  }
success "Disable compattelrunner.exe launched by scheduled tasks..."
info "Disable the Autologger session at the next computer restart"
  del C:\ProgramData\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl -ErrorAction SilentlyContinue
  Set-AutologgerConfig -Name 'AutoLogger-Diagtrack-Listener' -Start 0
success "Disable the Autologger session at the next computer restart"
success "Stopping and disabling Microsoft Compatibility Appraiser..."
}
Function DisableConnectedStandby {
  info "Disabling Connected Standby..."
  Safe-Set-ItemProperty "HKLM:\SYSTEM\\CurrentControlSet\Control\Power" "CSEnabled" DWord 0
  success "Disabling Connected Standby..."
}
Function EnableBigDesktopIcons {
  info "Enabling Big Desktop Icons..."
  Set-ItemProperty -path HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop -name IconSize -value 100
  success "Enabling Big Desktop Icons..."
}
Function RemoveUnneededComponents {
  info "Disabling Optional Feature..."
  foreach ($feature in $optional_features_to_remove) {
      try {
          info "Disabling: $feature"
          disable-windowsoptionalfeature -online -featureName $feature -NoRestart 
          success "Disabling: $feature"
      }
      catch{
          warn "could not disable $feature possibly due to fact that it does't exist."
      }
  }
  success "Disabling Optional Feature..."
}
Function DisableGPDWinServices {
info "Disabling extra services ..."
  $service="Spooler"
      if (Get-Service $service -ErrorAction SilentlyContinue)
      {
          info "Stopping and disabling $service"
          Stop-Service -Name $service
          Get-Service -Name $service | Set-Service -StartupType Disabled
      } else {
          warn "Skipping $service (does not exist)"
      }
success "Disabling extra services ..."
}
Function SetUACLow {
  info "Lowering UAC level..."
  $path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
  Safe-Set-ItemProperty "$path" "ConsentPromptBehaviorAdmin" DWord 0
  Safe-Set-ItemProperty "$path" "PromptOnSecureDesktop" DWord 0
  success "Lowering UAC level..."
}
Function DisableAdminShares {
info "Disabling implicit administrative shares..."
  $path="HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
  Safe-Set-ItemProperty "$path" "AutoShareWks" DWord 0
success "Disabling implicit administrative shares..."
}
Function EnableCtrldFolderAccess {
info "Enabling Controlled Folder Access..."
Set-MpPreference -EnableControlledFolderAccess Enabled
success "Enabling Controlled Folder Access..."
}
Function DisableFirewall {
info "Disabling Firewall..."
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" "EnableFirewall" DWord 0
success "Disabling Firewall..."
}
Function EnableFirewall {
info "Enabling Firewall..."
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Name "EnableFirewall" -ErrorAction SilentlyContinue
success "Enabling Firewall..."
}
Function DisableDefender {
info "Disabling Windows Defender..."
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" "DisableAntiSpyware" DWord 1
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -ErrorAction SilentlyContinue
success "Disabling Windows Defender..."
}
Function DisableDefenderCloud {
  info "Disabling Windows Defender Cloud..."
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SpynetReporting" DWord 0
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SubmitSamplesConsent" DWord 2
  success "Disabling Windows Defender Cloud..."
}
Function DisableUpdateMSRT {
info "Disabling Malicious Software Removal Tool offering..."
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Policies\Microsoft\MRT"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\MRT" "DontOfferThroughWUAU" DWord 1
success "Disabling Malicious Software Removal Tool offering..."
}
Function DisableUpdateDriver {
  info "Disabling driver offering through Windows Update..."
  $path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching"
  Safe-Set-ItemProperty "$path" "SearchOrderConfig" DWord 0
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "ExcludeWUDriversInQualityUpdate" DWord 1
success "Disabling driver offering through Windows Update..."
}
Function DisableUpdateRestart {
info "Disabling Windows Update automatic restart..."
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoRebootWithLoggedOnUsers" DWord 1
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "AUPowerManagement" DWord 0
success "Disabling Windows Update automatic restart..."
}
Function DisableSharedExperiences {
  info "Disabling Shared Experiences..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP"
  Safe-Set-ItemProperty "$path" "RomeSdkChannelUserAuthzPolicy" DWord 0
  success "Disabling Shared Experiences..."
}
Function DisableRemoteAssistance {
  info "Disabling Remote Assistance..."
  $path="HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance"
  Safe-Set-ItemProperty "$path" "fAllowToGetHelp" DWord 0
  success "Disabling Remote Assistance..."
}
Function DisableAutoplay {
  info "Disabling Autoplay..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers"
  Safe-Set-ItemProperty "$path" "DisableAutoplay" DWord 1
  success "Disabling Autoplay..."
}
Function EnableRemoteDesktop {
  info "Enabling Remote Desktop w/o Network Level Authentication..."
  $paths = @{
      'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' = 'fDenyTSConnections'
      'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' = 'UserAuthentication'
  }
  $paths.GetEnumerator() | ForEach-Object {
      $path=$_.Key
      Safe-Set-ItemProperty "$path"  $_.Value DWord 0
  }
  success "Enabling Remote Desktop w/o Network Level Authentication..."
}
Function DisableStorageSense {
info "Disabling Storage Sense..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy"
  Safe-Set-ItemProperty "$path" "01" DWord 0 
success "Disabling Storage Sense..."
}
Function DisableDefragmentation {
info "Disabling scheduled defragmentation..."
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Defrag\ScheduledDefrag" | Out-Null
success "Disabling scheduled defragmentation..."
}
Function DisableSuperfetch {
info "Stopping and disabling Superfetch service..."
Stop-Service "SysMain" -WarningAction SilentlyContinue
Set-Service "SysMain" -StartupType Disabled
success "Stopping and disabling Superfetch service..."
}
Function DisableIndexing {
info "Stopping and disabling Windows Search indexing service..."
Stop-Service "WSearch" -WarningAction SilentlyContinue
Set-Service "WSearch" -StartupType Disabled
success "Stopping and disabling Windows Search indexing service..."
}
Function SetBIOSTimeLocal {
info "Setting BIOS time to Local time..."
  $path="HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
  Safe-Remove-ItemProperty "$path" "RealTimeIsUniversal"
success "Setting BIOS time to Local time..."
}
Function DisableHibernation {
  info "Disabling Hibernation..."
  $path="HKLM:\System\CurrentControlSet\Control\Session Manager\Power"
  Safe-Set-ItemProperty "$path" "HibernteEnabled"  Dword  0
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" "ShowHibernateOption"  Dword  0
  Start-Process 'powercfg.exe' -Verb runAs -ArgumentList '/h off'
  success "Disabling Hibernation..."
}
Function DisableFastStartup {
  info "Disabling Fast Startup..."
  $path="HKLM:\System\CurrentControlSet\Control\Session Manager\Power"
  Safe-Set-ItemProperty "$path" "HiberbootEnabled" DWord 0
  success "Disabling Fast Startup..."
}
Function DisableExtraServices {
info "Disabling extra services ..."
  foreach ($service in $services_to_disable) {
      if (Get-Service $service -ErrorAction SilentlyContinue)
      {
          info "Stopping and disabling $service"
          Stop-Service -Name $service
          Get-Service -Name $service | Set-Service -StartupType Disabled
      } else {
          warn "Skipping $service (does not exist)"
      }
  }
success "Disabling extra services ..."
}
Function DisableAutorun {
info "Disabling Autorun for all drives..."
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoDriveTypeAutoRun" DWord 255
success "Disabling Autorun for all drives..."
}
Function DisableLockScreen {
info "Disabling Lock screen..."
  Create-Path-If-Not-Exists "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreen" DWord 1
success "Disabling Lock screen..."
}
Function EnableLockScreen {
  info "Enabling Lock screen..."
  $path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
  Safe-Remove-ItemProperty "$path" "NoLockScreen"
  success "Enabling Lock screen..."
}
Function DisableLockScreenRS1 {
info "Disabling Lock screen using scheduler workaround..."
$service = New-Object -com Schedule.Service
$service.Connect()
$task = $service.NewTask(0)
$task.Settings.DisallowStartIfOnBatteries = $false
$trigger = $task.Triggers.Create(9)
$trigger = $task.Triggers.Create(11)
$trigger.StateChange = 8
$action = $task.Actions.Create(0)
$action.Path = "reg.exe"
$action.Arguments = "add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\SessionData /t REG_DWORD /v AllowLockScreen /d 0 /f"
$service.GetFolder("\").RegisterTaskDefinition("Disable LockScreen", $task, 6, "NT AUTHORITY\SYSTEM", $null, 4) | Out-Null
success "Disabling Lock screen using scheduler workaround..."
}
Function EnableLockScreenRS1 {
info "Enabling Lock screen (removing scheduler workaround)..."
Unregister-ScheduledTask -TaskName "Disable LockScreen" -Confirm:$false -ErrorAction SilentlyContinue
success "Enabling Lock screen (removing scheduler workaround)..."
}
Function HideShutdownFromLockScreen {
  info "Hiding shutdown options from Lock Screen..."
  $path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
  Safe-Set-ItemProperty "$path" "ShutdownWithoutLogon" DWord 0
  success "Hiding shutdown options from Lock Screen..."
}
Function ShowShutdownOnLockScreen {
  info "Showing shutdown options on Lock Screen..."
  $path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
  Safe-Set-ItemProperty "$path" "ShutdownWithoutLogon" DWord 1
  success "Showing shutdown options on Lock Screen..."
}
Function DisableStickyKeys {
  info "Disabling Sticky keys prompt..."
  $path="HKCU:\Control Panel\Accessibility\StickyKeys"
  Safe-Set-ItemProperty "$path" "Flags" String "506"
  success "Disabling Sticky keys prompt..."
}
Function EnableStickyKeys {
  info "Enabling Sticky keys prompt..."
  $path="HKCU:\Control Panel\Accessibility\StickyKeys"
  Safe-Set-ItemProperty "$path" "Flags" String "510"
  success "Enabling Sticky keys prompt..."
}
Function HideTaskbarSearchBox {
  info "Hiding Taskbar Search box / button..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
  Safe-Set-ItemProperty "$path" "SearchboxTaskbarMode" DWord 0
  success "Hiding Taskbar Search box / button..."
}
Function ShowTaskbarSearchBox {
  info "Showing Taskbar Search box / button..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
  Safe-Remove-ItemProperty "$path" "SearchboxTaskbarMode"
  success "Showing Taskbar Search box / button..."
}
Function HideTaskView {
  info "Hiding Task View button..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  Safe-Set-ItemProperty "$path" "ShowTaskViewButton" DWord 0
  success "Hiding Task View button..."
}
Function ShowTaskView {
  info "Showing Task View button..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  Safe-Remove-ItemProperty "$path" "ShowTaskViewButton"
  success "Showing Task View button..."
}
Function ShowSmallTaskbarIcons {
  info "Showing small icons in taskbar..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  Safe-Set-ItemProperty "$path" "TaskbarSmallIcons" DWord 1
  success "Showing small icons in taskbar..."
}
Function ShowLargeTaskbarIcons {
  info "Showing large icons in taskbar..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  Safe-Remove-ItemProperty "$path" "TaskbarSmallIcons"
  success "Showing large icons in taskbar..."
}
Function ShowTaskbarTitles {
  info "Showing titles in taskbar..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  Safe-Set-ItemProperty "$path" "TaskbarGlomLevel" DWord 1
  success "Showing titles in taskbar..."
}
Function HideTaskbarTitles {
  info "Hiding titles in taskbar..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  Safe-Remove-ItemProperty "$path" "TaskbarGlomLevel"
  success "Hiding titles in taskbar..."
}
Function ShowTaskManagerDetails {
info "Showing task manager details..."
  Create-Path-If-Not-Exists "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager"
$preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
If (!($preferences)) {
  $taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
  While (!($preferences)) {
    Start-Sleep -m 250
    $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
  }
  Stop-Process $taskmgr
}
$preferences.Preferences[28] = 0
  Safe-Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" "Preferences" Binary $preferences.Preferences
success "Showing task manager details..."
}
Function HideTaskManagerDetails {
info "Hiding task manager details..."
$preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
If ($preferences) {
  $preferences.Preferences[28] = 1
      Safe-Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" "Preferences" Binary $preferences.Preferences
}
success "Hiding task manager details..."
}
Function ShowFileOperationsDetails {
info "Showing file operations details..."
  Create-Path-If-Not-Exists "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager"
  Safe-Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" "EnthusiastMode" DWord 1
success "Showing file operations details..."
}
Function HideFileOperationsDetails {
  info "Hiding file operations details..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager"
  Safe-Remove-ItemProperty "$path" "EnthusiastMode"
  success "Hiding file operations details..."
}
Function Hide3DObjectsFromThisPC {
  info "Hiding 3D Objects icon from This PC..."
  $path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
  # If (Test-Path "$path") {
      Remove-Item  -Path "$path" -Recurse -ErrorAction SilentlyContinue
  # }
  success "Hiding 3D Objects icon from This PC..."
}
Function HideTaskbarPeopleIcon {
info "Hiding People icon..."
  Create-Path-If-Not-Exists "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
  Safe-Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" "PeopleBand" DWord 0
success "Hiding People icon..."
}
Function ShowTrayIcons {
  info "Showing all tray icons..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
  Safe-Set-ItemProperty "$path" "EnableAutoTray" DWord 0
  success "Showing all tray icons..."
}
Function ShowKnownExtensions {
  info "Showing known file extensions..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  Safe-Set-ItemProperty "$path" "HideFileExt" DWord 0
  success "Showing known file extensions..."
}
Function ShowHiddenFiles {
  info "Showing hidden files..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  Safe-Set-ItemProperty "$path" "Hidden" DWord 1
  success "Showing hidden files..."
}
Function HideSyncNotifications {
  info "Hiding sync provider notifications..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  Safe-Set-ItemProperty "$path" "ShowSyncProviderNotifications" DWord 0
  success "Hiding sync provider notifications..."
}
Function HideRecentShortcuts {
  info "Hiding recent shortcuts..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
  $names=@(
      "ShowRecent", 
      "ShowFrequent"
  )
  foreach($name in $names) {
      Safe-Set-ItemProperty "$path" "$name" DWord 0
  }
  success "Hiding recent shortcuts..."
}
Function SetExplorerThisPC {
  info "Changing default Explorer view to This PC..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  Safe-Set-ItemProperty "$path" "LaunchTo" DWord 1
  success "Changing default Explorer view to This PC..."
}
Function ShowThisPCOnDesktop {
  info "Showing This PC shortcut on desktop..."
  $paths = @{
      'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' = '{20D04FE0-3AEA-1069-A2D8-08002B30309D}'
      'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' = '{20D04FE0-3AEA-1069-A2D8-08002B30309D}'
  }
  $paths.GetEnumerator() | ForEach-Object {
      $path=$_.Key
      Create-Path-If-Not-Exists "$path"
      Safe-Set-ItemProperty "$path"  $_.Value DWord 0
  }
success "Showing This PC shortcut on desktop..."
}
Function ShowUserFolderOnDesktop {
info "Showing User Folder shortcut on desktop..."
  Create-Path-If-Not-Exists "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu"
  Safe-Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" DWord 0
  Create-Path-If-Not-Exists "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
  Safe-Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" DWord 0
success "Showing User Folder shortcut on desktop..."
}
Function SetVisualFXPerformance {
info "Adjusting visual effects for performance..."
  # turn off transparency
  Reg Add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f

  Safe-Set-ItemProperty "HKCU:\Control Panel\Desktop" "DragFullWindows" String 0
  Safe-Set-ItemProperty "HKCU:\Control Panel\Desktop" "MenuShowDelay" String 0
  Safe-Set-ItemProperty "HKCU:\Control Panel\Desktop\WindowMetrics" "MinAnimate" String 0
  Safe-Set-ItemProperty "HKCU:\Control Panel\Desktop" "UserPreferencesMask" Binary ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))
  Safe-Set-ItemProperty "HKCU:\Control Panel\Keyboard" "KeyboardDelay" DWord 0
  Safe-Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewAlphaSelect" DWord 0
  Safe-Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewShadow" DWord 0
  Safe-Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" DWord 0
  Safe-Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" DWord 3
  Safe-Set-ItemProperty "HKCU:\Software\Microsoft\Windows\DWM" "EnableAeroPeek" DWord 0
success "Adjusting visual effects for performance..."
}
Function DisableThumbnails {
  info "Disabling thumbnails..."
  $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  Safe-Set-ItemProperty "$path" "IconsOnly" DWord 1
  success "Disabling thumbnails..."
}
Function DisableThumbsDB {
  info "Disabling creation of Thumbs.db..."
  $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  Safe-Set-ItemProperty "$path" "DisableThumbnailCache" DWord 1
  Safe-Set-ItemProperty "$path" "DisableThumbsDBOnNetworkFolders" DWord 1
  success "Disabling creation of Thumbs.db..."
}
Function EnableNumlock {
info "Enabling NumLock after startup..."
If (!(Test-Path "HKU:")) {
  New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
  }
  $path="HKU:\.DEFAULT\Control Panel\Keyboard"
  Safe-Set-ItemProperty "$path" "InitialKeyboardIndicators" DWord 2147483650
Add-Type -AssemblyName System.Windows.Forms
If (!([System.Windows.Forms.Control]::IsKeyLocked('NumLock'))) {
  $wsh = New-Object -ComObject WScript.Shell
  $wsh.SendKeys('{NUMLOCK}')
}
success "Enabling NumLock after startup..."
}
Function EnableFileDeleteConfirm {
info "Enabling file delete confirmation dialog..."
  Create-Path-If-Not-Exists "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
  Safe-Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "ConfirmFileDelete" DWord 1
success "Enabling file delete confirmation dialog..."
}
Function DisableFileDeleteConfirm {
  info "Disabling file delete confirmation dialog..."
  $path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
  Safe-Remove-ItemProperty "$path" "ConfirmFileDelete"
  success "Disabling file delete confirmation dialog..."
}
Function HideTaskbarSearchBox {
  info "Hiding Taskbar Search box / button..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
  Safe-Set-ItemProperty "$path" "SearchboxTaskbarMode" DWord 0
  success "Hiding Taskbar Search box / button..."
}
Function ShowTaskbarSearchBox {
  info "Showing Taskbar Search box / button..."
  $path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
  Safe-Remove-ItemProperty "$path" "SearchboxTaskbarMode"
  success "Showing Taskbar Search box / button..."
}
Function SetDEPOptOut {
  info "Setting Data Execution Prevention (DEP) policy to OptOut..."
  try {
      bcdedit /set `{current`} nx OptOut | Out-Null
      success "Setting Data Execution Prevention (DEP) policy to OptOut..."
  }
  catch{
      warn "could not ser Data Execution Prevention (DEP) policy to OptOut. Possibly, bcdedit was not present in path"
  }
}
foreach($tweak in $tweaks) {
Invoke-Expression $tweak
}