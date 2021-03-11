#Requires -Version 5
# ────────────────────────────────────────────────────────────────────────────────
# powershell -executionpolicy bypass -File apps.ps1
# ────────────────────────────────────────────────────────────────────────────────
#	Set-ExecutionPolicy RemoteSigned -scope CurrentUser
#	iwr -useb 'https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/powershell/apps.ps1'| iex
# ────────────────────────────────────────────────────────────────────────────────

# Check OS and ensure we are running on Windows
if (-Not ($Env:OS -eq "Windows_NT")) {
  Write-Host "Error: This script only supports Windows machines. Exiting..."
  exit 1
}
# Start-Process powershell -ArgumentList "scoop install --skip --global $app" -Wait -NoNewWindow
# [ NOTE ] 
#   - https://github.com/benallred/configs/blob/master/config-functions.ps1
#   - https://github.com/MarkMichaelis/ScoopBucket/blob/master/bucket/Utils.ps1
$core_cli_tools = @(
  "7zip",
  "Lessmsi",
  "Innounp", 
  "Dark",
  "unzip",
  "zip",
  "unrar",
  "cygwin",
  "coreutils",
  "dd",
  "win32-openssh",
  "shasum"
)

$development_tools = @(
  "vim",
  "nano",
  "vscode",
  "nodejs",
  "python",
  "yarn"
)

$network_tools = @(
  "wget",
  "curl",
  "zip",
  "aria2",
  "axel",
  "jq"
)
$devops_tools = @(
  "terraform",
  "vault",
  "consul",
  "gcloud",
  "minikube",
  "kubectl"
)
$rust_cli_tools = @(
  "bat",
  "ripgrep",
  "glow",
  "windows-terminal",
  "nu",
  "starship",
  "vcredist2019",
  "tokei"
)
$gui_software = @(
  "memreduct",
  "bulk-crap-uninstaller",
  "vcxsrv",
  "slack",
  "firefox"
)
$python_software = @(
  "ansible",
  "ansible-lint",
  "ansible-tower-cli"
)

$scoop_software = `
  $core_cli_tools + `
  $development_tools + `
  $network_tools + `
  $devops_tools + `
  $rust_cli_tools + `
  $gui_software
# [ NOTE ] install docker in wsl
# sudo apt-get install docker-ce=18.06.1~ce~3-0~ubuntu
# [ NOTE ] docker-toolbox guide
# https://medium.com/@peorth/using-docker-with-virtualbox-and-windows-10-b351e7a34adc
$chocolatey_software = @(
# "docker-desktop"
)

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

function add_line_to_file([string] $line,[string] $path){
  $parent=Split-Path -parent $path 
  if (-not(Test-Path -Path $parent -PathType Container)) {
    warn "The directory [$parent] does not exist.trying to create it."
    try {
      $null = New-Item -ItemType Directory -Path $parent -Force -ErrorAction Stop
      info "The directory [$parent] has been created."
    }
    catch {
      throw $_.Exception.Message
    }
  }
  if (-not(Test-Path -Path $path -PathType Leaf)) {
    try {
      $null = New-Item -ItemType File -Path $path -Force -ErrorAction Stop
      info "The file [$path] has been created."
    }
    catch {
      throw $_.Exception.Message
    }
  }
	If (!(Select-String -Path $path -pattern $line)){
		$line | Out-File "$path"  -Encoding ascii -Append
	}
}
function add_line_to_profile([string] $line){
  add_line_to_file "$line" $PROFILE.CurrentUserAllHosts
}
function test_command([Parameter(Mandatory)][string]$command) {
  return [bool](Get-Command $command -ErrorAction Ignore)
}
function is_chocolatey_package_installed([Parameter(Mandatory)][string]$app) {
  $installed = choco list $app --local-only --no-progress | Where-Object {
    # Alternate filter
    #choco list  -localonly | Where-Object { ($_ -notmatch 'Chocolatey v[0-9\.]') -and $_ -notmatch '\d+ packages installed\.' }
    $_ -match "$app\s.*"
  }
  return [bool](Write-Output (@($installed).Count -gt 0))
}
function is_scoop_package_installed([Parameter(Mandatory)][string]$app) {
  $scoopOutput = scoop export $app
  $installed = $scoopOutput | Where-Object {
  # Alternate filter
  #choco list  -localonly | Where-Object { ($_ -notmatch 'Chocolatey v[0-9\.]') -and $_ -notmatch '\d+ packages installed\.' }
  $_ -match "\s*$app\s.*"
  }
  return [bool](Write-Output (@($installed).Count -gt 0))
}

function scoop_install([string] $app) {
  if (is_scoop_package_installed "$app"){
  warn "'$app' is installed. skipping."
  return
  }
  info "Installing '$app' Software With scoop"
  scoop install --skip --global $app
  success "scoop was able to install '$app' successfully"

}
function choco_install([string] $app) {
  if (is_chocolatey_package_installed "$app"){
  warn "'$app' is installed. skipping."
  return
  }
  info "Installing '$app' Software With Chocolatey"
  scoop install --skip --global $app
  success "Chocolatey was able to install '$app' successfully"
}
function install_chrome {
  info "installing chrome"
  $chrome_installer_url="https://dl.google.com/chrome/install/latest/chrome_installer.exe"
  $P=$env:TEMP+"\chrome_installer.exe"
  $start_time = Get-Date
  Set-ExecutionPolicy Bypass -Scope Process -Force
  [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
  Invoke-WebRequest "$chrome_installer_url" -OutFile $P
  Start-Process -FilePath $P -Args '/install' -Verb RunAs -Wait
  Remove-Item $P
  debug "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}
function install_chrome_remote_desktop{
  info "installing chrome remote desktop"
  $chrome_rdp_installer_url="https://dl.google.com/edgedl/chrome-remote-desktop/chromeremotedesktophost.msi"
  $P=$env:TEMP+"\chromeremotedesktophost.msi"
  $start_time = Get-Date
  Set-ExecutionPolicy Bypass -Scope Process -Force
  [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
  Invoke-WebRequest "$chrome_rdp_installer_url" -OutFile $P
  Start-Process $P -Wait
  Remove-Item $P
  debug "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}
function RequireAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
		Exit
	}
}
RequireAdmin
# Test if running as administrator
# http://serverfault.com/questions/95431
function Test-Elevated {
  # Get the ID and security principal of the current user account
  $userID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
  $userPrincipal = New-Object System.Security.Principal.WindowsPrincipal($userID)
  # Check to see if we are currently running "as Administrator"
  return $userPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

info "ensure the script was started 'as Administrator'"
if (!(Test-Elevated)) {
  $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
  $newProcess.Arguments = $myInvocation.MyCommand.Definition;
  $newProcess.Verb = "runas";
  [System.Diagnostics.Process]::Start($newProcess);
  exit
}

# show notification to change execution policy:
$allowedExecutionPolicy = @('Unrestricted', 'RemoteSigned', 'ByPass')
if ((Get-ExecutionPolicy).ToString() -notin $allowedExecutionPolicy) {
  Write-Output "PowerShell requires an execution policy in [$($allowedExecutionPolicy -join ", ")] to run $script_name script."
  Write-Output "For example, to set the execution policy to 'RemoteSigned' please run :"
  Write-Output "'Set-ExecutionPolicy RemoteSigned -scope CurrentUser'"
  break
}
#install_chrome
#install_chrome_remote_desktop
if ( -Not (test_command "scoop") ) 
{ 
	warn "Unable to find scoop in your PATH.installing scoop"
  iwr -useb get.scoop.sh | iex
  success "Scoop was Installed successfully"
}
if ( test_command "scoop" ) 
{ 
	info "Scoop detected"
  info "ensuring git is installed"
  scoop_install "git"
	info "ensuring scoop 'extras' bucket is added"
  scoop bucket add extras
	foreach($app in $scoop_software) {
		scoop_install $app 
	}
}
# [ NOTE ] https://stackoverflow.com/questions/46758437/how-to-refresh-the-environment-of-a-powershell-session-after-a-chocolatey-instal
if ( -Not (test_command "choco")) 
{ 
	warn "Unable to find choco in your PATH.Installing Chocolatey ..."
	iwr -useb https://chocolatey.org/install.ps1 | iex -ErrorAction SilentlyContinue
	success "Chocolatey was installed successfully"
}
if ( test_command "choco" ) 
{ 
	info "Chocolatey detected"
	info "making sure chocolatey does not ask for approval before installing a package"
	choco feature enable -n allowGlobalConfirmation
	foreach($app in $chocolatey_software) {
  choco_install $app
  }
}
if ( test_command "pip3" ) 
{
  foreach($app in $python_software) {
      info "installing [$app]."
      pip3 install $app
      info "[$app] install was successful."
  }
}
if ( test_command "code" ) 
{ 
	info "VS Code detected. Adding it as a context menu option"
	reg import "$HOME\scoop\apps\vscode\current\vscode-install-context.reg"
	if (test_command "git") 
	{ 
	info "setting VS code as default git editor"
	git config --global core.editor "code --wait"
	}
}
if (test_command "terraform") 
{ 
	info "Terraform detected. Adding aliases"
	add_line_to_profile 'function tf([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform $params }'
	add_line_to_profile 'function tfi([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform init $params }'
	add_line_to_profile 'function tfa([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform apply -auto-approve $params }'
	add_line_to_profile 'function tfd([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform destroy -auto-approve $params }'
	add_line_to_profile 'function tfp([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform plan $params }'
	add_line_to_profile 'function tfw([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform workspace $params }'
	add_line_to_profile 'function tfwl([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform workspace list $params }'
	add_line_to_profile 'function tfws([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform workspace select $params }'
	add_line_to_profile 'function tfo([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform output $params }'
	. $PROFILE.CurrentUserAllHosts
}
if ( test_command "starship" ) 
{ 
	info "starship detected. updating profile"
	add_line_to_profile 'Invoke-Expression (&starship init powershell)'
	 . $PROFILE.CurrentUserAllHosts
}
# if ( test_command "WindowsTerminal" ) 
# { 
# 	info "windows-terminal detected. setting color scheme to Solarized Dark"

#   (Get-Content "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json" -ErrorAction SilentlyContinue) | 
#   Select-String -pattern 'colorScheme' -notmatch | 
#   Out-File "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
#   Start-Sleep -Seconds 1.5
#   info "initializing windows-terminal";
#   $p = [diagnostics.process]::start("WindowsTerminal.exe")
#   # $p = Start-Process WindowsTerminal -passthru
#   if ( ! $p.WaitForExit(1000) ) 
#   { 
#   info "killing 'windows-terminal' process after 1000ms";
#   # $p.Kill()
#   taskkill /T /F /PID $p.ID
#   # $p | Get-Member
#   success "windows-terminal was initialized";
#   }
#   Start-Sleep -Seconds 1.5
#   (Get-Content "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json" -ErrorAction SilentlyContinue ) | 
#   Foreach-Object {
#     $_ # send the current line to output
#     if ($_ -match "guid")
#     {
#       #Add Lines after the selected pattern 
#       '"colorScheme": "Solarized Dark",'
#     }
#   } | Set-Content "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
# }

#'$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json'
#"colorScheme": "Solarized Dark",
