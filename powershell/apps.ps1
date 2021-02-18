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
    "brave"
)
$devops_tools = @(
 "terraform",
 "vault",
 "consul",
 "gcloud",
 "minikube",
 "kubectl"
)
$chocolatey_software = @(
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

function InstallDevopsPackages{
    info "Installing Requested Software With Scoop ..."
    foreach($app in $devops_tools) {
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
InstallDevopsPackages
if ((Get-Command "code" -ErrorAction SilentlyContinue) -ne $null) 
{ 
	info "VS Code detected. Adding it as a context menu option"
	reg import "$HOME\scoop\apps\vscode\current\vscode-install-context.reg"
	if ((Get-Command "git" -ErrorAction SilentlyContinue) -ne $null) 
	{ 
	info "setting VS code as default git editor"
	git config --global core.editor "code --wait"
	}
}
if ((Get-Command "terraform" -ErrorAction SilentlyContinue) -ne $null) 
{ 
	write-host "Terraform detected. Adding aliases"
	new-item $profile.CurrentUserAllHosts -ItemType file –Force
	'function tf([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfi([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform init $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfa([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform apply -auto-approve $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfd([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform destroy -auto-approve $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfp([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform plan $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfw([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform workspace $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfwl([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform workspace list $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfws([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform workspace select $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfo([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform output $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
}
