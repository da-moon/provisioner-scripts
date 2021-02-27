
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
Function RequireAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
		Exit
	}
}
Function InstallScoop {
  info "Installing and conifiguring Scoop  ..."
  info "Installing Up Scoop ..."
  iwr -useb get.scoop.sh | iex
  success "Installing Up Scoop ..."
  info "Installing git ..."
  scoop install git
  success "Installing git ..."
  info "adding scoop extras bucket ..."
  scoop bucket add extras
  success "adding scoop extras bucket ..."
  success "Installing and conifiguring Scoop  ..."
}
function Confirm-Aria2 {
  if ((Get-Command "aria2c" -ErrorAction SilentlyContinue) -eq $null) 
  { 
    warn "Unable to find aria2c in your PATH"
    if ((Get-Command "scoop" -ErrorAction SilentlyContinue) -eq $null) 
    { 
      warn "Unable to find scoop in your PATH"
      info "installing scoop"
      InstallScoop
    }
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
Function InstallLinuxSubsystem {
  info "Installing Linux Subsystem..."
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowDevelopmentWithoutDevLicense" DWord 1
  Safe-Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowAllTrustedApps" DWord 1
  Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue | Out-Null
  info "enbling Virtual Machine Platform component ..."
  Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -NoRestart -WarningAction SilentlyContinue | Out-Null
  $url="https://aka.ms/wsl-ubuntu-1804"
  $dir=pwd
  $file="ubuntu.appx"
  aria2_dl "$url" "$dir" "$file"
  try {
    info "installing $file"
    Add-AppxPackage "$dir\$file"
    success "installing $file"
    info "cleaning up e $dir\$file"
    Remove-Item -Path "$dir\$file" -Recurse -Force -ErrorAction SilentlyContinue
    success "Installing Linux Subsystem..."
  }
  catch{
    warn "could not install $file"
    info "cleaning up e $dir\$file"
    Remove-Item -Path "$dir\$file" -Recurse -Force -ErrorAction SilentlyContinue
  }
}

# show notification to change execution policy:
$allowedExecutionPolicy = @('Unrestricted', 'RemoteSigned', 'ByPass')
if ((Get-ExecutionPolicy).ToString() -notin $allowedExecutionPolicy) {
  Write-Output "PowerShell requires an execution policy in [$($allowedExecutionPolicy -join ", ")] to run $script_name script."
  Write-Output "For example, to set the execution policy to 'RemoteSigned' please run :"
  Write-Output "'Set-ExecutionPolicy RemoteSigned -scope CurrentUser'"
  break
}
RequireAdmin
InstallLinuxSubsystem
