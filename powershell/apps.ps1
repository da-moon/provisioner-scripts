#Requires -Version 5
$package_managers = @(
    "InstallScoop",
    "InstallChocolatey"
)
$scoop_software = @(
    "7zip",
    "Lessmsi",
    "Innounp", 
    "Dark",
    "wget",
    "curl",
    "unzip",
    "zip",
    "unrar",
    "aria2",
    "axel",
    "cygwin",
    "jq",
    "memreduct",
    "bulk-crap-uninstaller",
    "yarn",
    "nodejs",
    "vcxsrv",
    "vscode",
    "shasum",
    "coreutils",
    "dd",
    "win32-openssh",
    "nano",
    "vim",
    "slack",
    "firefox",
    "windows-terminal",
    
)
$chocolatey_software = @(
 "terraform",
 "brave",
 "google-cloud-sdk",
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
function InstallScoopPackages{
    info "Installing Requested Software With Scoop ..."
    foreach($app in $scoop_software) {
        scoop install -s $app
    }
    success "Installing Requested Software With Scoop ..."
}
Function InstallChocolatey {
    info "Installing Up Chocolatey ..."
    iwr -useb https://chocolatey.org/install.ps1 | iex
    success "Installing Up Chocolatey ..."
}
function InstallChocolateyPackages{
    info "Installing Requested Software With Chocolatey ..."
    foreach($app in $chocolatey_software) {
        choco install -y $app
    }
    success "Installing Requested Software With Chocolatey ..."
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
# parsing flags
if ((Get-Command "scoop" -ErrorAction SilentlyContinue) -eq $null) 
{ 
	warn "Unable to find scoop in your PATH"
	info "installing scoop"
	InstallScoop
}
if ((Get-Command "choco" -ErrorAction SilentlyContinue) -eq $null) 
{ 
	warn "Unable to find choco in your PATH"
	info "installing chocolatey"
	InstallChocolatey
}
choco feature enable -n allowGlobalConfirmation
InstallScoopPackages
InstallChocolateyPackages
if ((Get-Command "code" -ErrorAction SilentlyContinue) -ne $null) 
{ 
	info "VS Code detected. Adding it as a context menu option"
	reg import "$HOME\scoop\apps\vscode\current\vscode-install-context.reg"
}

