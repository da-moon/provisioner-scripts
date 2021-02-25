#Requires -Version 5

# powershell -executionpolicy bypass -File apps.ps1
# Start-Process powershell -ArgumentList "scoop install --skip --global $app" -Wait -NoNewWindow
# [ NOTE ] 
#   - https://github.com/benallred/configs/blob/master/config-functions.ps1
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
    debug "add_line_to_file $path"
    if (-not(Test-Path -Path $path -PathType Leaf)) {
        warn "The file [$path] does not exist.trying to create it."
        try {
            $null = New-Item -ItemType File -Path $path -Force -ErrorAction Stop
            info "The file [$path] has been created."
        }
        catch {
            throw $_.Exception.Message
        }
    }
	If (!(Select-String -Path $path -pattern $line)){
        debug "writing $path"
		$line | Out-File "$path"  -Encoding ascii -Append
	}
}
function add_line_to_profile([string] $line){
    add_line_to_file "$line" $PROFILE.CurrentUserAllHosts
}
function scoop_install([string] $app) {
    if ((scoop prefix "$app" ) -eq $null) 
    { 
        warn "scoop has already installed '$app'. skipping"
        return 0
    }
    info "Installing '$app' Software With scoop"
    $log=$env:TEMP+"\test.log"
    debug "$log"
    powershell -executionpolicy bypass -ArgumentList "scoop install -s -g $app" -PassThru 
    $process = Start-Process powershell  -ArgumentList "scoop install -s -g $app" -PassThru 
     -RedirectStandardOutput $log
    
    $app="bruh"
    $args = "scoop install --skip --global $app"

    $process = Start-Process powershell -ArgumentList "scoop install --skip --global $app" -Wait -NoNewWindow
    out-null
    Start-Process powershell -ArgumentList "scoop install" -Wait -NoNewWindow | Get-Member
    success "scoop was able to install '$app' successfully"
}
"--skip" "--global" "$app" 
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
if ((Get-Command "scoop" -ErrorAction SilentlyContinue) -eq $null) 
{ 
	warn "Unable to find scoop in your PATH.installing scoop"
    iwr -useb get.scoop.sh | iex
    success "Scoop was Installed successfully"
}
if ((Get-Command "scoop" -ErrorAction SilentlyContinue) -ne $null) 
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
# # [ NOTE ] https://stackoverflow.com/questions/46758437/how-to-refresh-the-environment-of-a-powershell-session-after-a-chocolatey-instal
# if ((Get-Command "choco" -ErrorAction SilentlyContinue) -eq $null) 
# { 
# 	warn "Unable to find choco in your PATH.Installing Chocolatey ..."
# 	iwr -useb https://chocolatey.org/install.ps1 | iex -ErrorAction SilentlyContinue
# 	success "Chocolatey was installed successfully"
# }
# if ((Get-Command "choco" -ErrorAction SilentlyContinue) -ne $null) 
# { 
# 	info "Chocolatey detected"
# 	info "making sure chocolatey does not ask for approval before installing a package"
# 	choco feature enable -n allowGlobalConfirmation
# 	foreach($app in $chocolatey_software) {
# 		info "Installing '$app' Software With Chocolatey"
#         	choco install -y $app
# 		success "chocolatey was able to install '$app' successfully"
#     	}
# }
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
if ((Get-Command "starship" -ErrorAction SilentlyContinue) -ne $null) 
{ 
	info "starship detected. updating profile"
	add_line_to_profile 'Invoke-Expression (&starship init powershell)'
	 . $PROFILE.CurrentUserAllHosts
}
#'C:/Users/vagrant/AppData/Local/Microsoft/Windows Terminal/settings.json'
#"colorScheme": "Solarized Dark",
