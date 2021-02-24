#Requires -Version 5

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

$scoop_software = $core_cli_tools + $development_tools + $network_tools + $devops_tools + $rust_cli_tools + $gui_software
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
Function RequireAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
		Exit
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
# parsing flags
if ((Get-Command "scoop" -ErrorAction SilentlyContinue) -eq $null) 
{ 
	warn "Unable to find scoop in your PATH.installing scoop"
    	iwr -useb get.scoop.sh | iex -ErrorAction SilentlyContinue
    	success "Scoop was Installed successfully"
}
if ((Get-Command "scoop" -ErrorAction SilentlyContinue) -ne $null) 
{ 
	info "Scoop detected"
    	info "ensuring git is installed"
    	scoop install git
	info "ensuring scoop 'extras' bucket is added"
    	scoop bucket add extras
	foreach($app in $scoop_software) {
		info "Installing '$app' Software With scoop"
		scoop install -s -g $app 
		success "scoop was able to install '$app' successfully"
	}
}
# [ NOTE ] https://stackoverflow.com/questions/46758437/how-to-refresh-the-environment-of-a-powershell-session-after-a-chocolatey-instal
if ((Get-Command "choco" -ErrorAction SilentlyContinue) -eq $null) 
{ 
	warn "Unable to find choco in your PATH.Installing Chocolatey ..."
	iwr -useb https://chocolatey.org/install.ps1 | iex -ErrorAction SilentlyContinue
	success "Chocolatey was installed successfully"
}
if ((Get-Command "choco" -ErrorAction SilentlyContinue) -ne $null) 
{ 
	info "Chocolatey detected"
	info "making sure chocolatey does not ask for approval before installing a package"
	choco feature enable -n allowGlobalConfirmation
	foreach($app in $chocolatey_software) {
		info "Installing '$app' Software With Chocolatey"
        	choco install -y $app
		success "chocolatey was able to install '$app' successfully"
    	}
}
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
	info "Terraform detected. Adding aliases"
	new-item $profile.CurrentUserAllHosts -ItemType file -ErrorAction SilentlyContinue
	'function tf([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfi([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform init $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfa([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform apply -auto-approve $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfd([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform destroy -auto-approve $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfp([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform plan $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfw([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform workspace $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfwl([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform workspace list $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfws([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform workspace select $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	'function tfo([Parameter(ValueFromRemainingArguments = $true)]$params) { & terraform output $params }' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	. $PROFILE.CurrentUserAllHosts
}
if ((Get-Command "starship" -ErrorAction SilentlyContinue) -ne $null) 
{ 
	write-host "starship detected. updating profile"
	new-item $profile.CurrentUserAllHosts -ItemType file -ErrorAction SilentlyContinue
	'Invoke-Expression (&starship init powershell)' | Out-File $PROFILE.CurrentUserAllHosts -Encoding ascii -Append
	 . $PROFILE.CurrentUserAllHosts
}
#'C:/Users/vagrant/AppData/Local/Microsoft/Windows Terminal/settings.json'
#"colorScheme": "Solarized Dark",
