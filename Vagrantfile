# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'getoptlong'
# [ NOTE ] => https://github.com/EA31337/EA-Tester/blob/master/Vagrantfile
opts = GetoptLong.new(
  [ '--ubuntu',          GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--debian',          GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--arch',            GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--provider',        GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--vm-name',         GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--memory',          GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--cpus',            GetoptLong::OPTIONAL_ARGUMENT ],
)
box            = ENV['BOX']      || "generic/debian10"
memory         = ENV['MEMORY']   || 4096
cpus           = ENV['CPUS']     || 4
provider       = ENV['PROVIDER'] || 'virtualbox'
vm_name        = ENV['VM_NAME']  || File.basename(Dir.pwd)

begin
  opts.each do |opt, arg|
    case opt
      when '--ubuntu';          box            = "generic/ubuntu2010"
      when '--debian';          box            = "generic/debian10"
      when '--arch';            box            = "generic/arch"
      when '--provider';        provider       = arg
      when '--vm-name';         vm_name        = arg
      when '--memory';          memory         = arg.to_i
      when '--cpus';            cpus           = arg.to_i
      end
  end
rescue
end
ENV['VAGRANT_DEFAULT_PROVIDER'] = provider
$cleanup_script = <<-SCRIPT
sudo apt-get autoremove -yqq --purge > /dev/null 2>&1
sudo apt-get autoclean -yqq > /dev/null 2>&1
sudo apt-get clean -qq > /dev/null 2>&1
sudo rm -rf /var/lib/apt/lists/*
SCRIPT
INSTALLER_SCRIPTS_BASE_URL="https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/installer"
UTIL_SCRIPTS_BASE_URL="https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/util"
INSTALLER_SCRIPTS_BASE_PATH="bash/installer"
UTIL_SCRIPTS_BASE_PATH="bash/util"
Vagrant.configure("2") do |config|
  config.vm.define "#{vm_name}"
  config.vm.hostname = "#{vm_name}"
  config.vagrant.plugins=["vagrant-vbguest"]
  config.vm.synced_folder ".", "/vagrant/#{vm_name}", disabled: true,auto_correct:true
  config.vm.box = "#{box}"
  config.vm.provider "virtualbox" do |vb, override|
    vb.memory = "#{memory}"
    vb.cpus   = "#{cpus}"
    # => enable nested virtualization
    vb.customize [
                  "modifyvm",:id,
                  "--nested-hw-virt", "on",
                  # "--paravirtprovider", "kvm",
                ]    
    override.vm.synced_folder ".", "/vagrant/#{File.basename(Dir.pwd)}", owner: "vagrant",group: "vagrant", type: "virtualbox"
  end
  config.vm.provision "shell",privileged:false,name:"cleanup", inline: $cleanup_script
  config.vm.provision "shell",privileged:false,name:"init", path: "#{INSTALLER_SCRIPTS_BASE_PATH}/init"
  config.vm.provision "shell",privileged:false,name:"node", path: "#{INSTALLER_SCRIPTS_BASE_PATH}/node"
  config.vm.provision "shell",privileged:false,name:"python", path: "#{INSTALLER_SCRIPTS_BASE_PATH}/python"
  config.vm.provision "shell",privileged:false,name:"starship", path: "#{INSTALLER_SCRIPTS_BASE_PATH}/starship"
  config.vm.provision "shell",privileged:false,name:"nu", path: "#{INSTALLER_SCRIPTS_BASE_PATH}/nu"
  config.vm.provision "shell",privileged:false,name:"goenv", path: "#{INSTALLER_SCRIPTS_BASE_PATH}/goenv"
  config.vm.provision "shell",privileged:false,name:"spacevim", path: "#{INSTALLER_SCRIPTS_BASE_PATH}/spacevim"
  config.vm.provision "shell",privileged:false,name:"hashicorp", path: "#{INSTALLER_SCRIPTS_BASE_PATH}/hashicorp"
  config.vm.provision "shell",privileged:false,name:"ripgrep", path: "#{INSTALLER_SCRIPTS_BASE_PATH}/ripgrep"
  config.vm.provision "shell",privileged:false,name:"docker", path: "#{INSTALLER_SCRIPTS_BASE_PATH}/docker"
  config.vm.provision "shell",privileged:false,name:"lxd", path: "#{INSTALLER_SCRIPTS_BASE_PATH}/lxd"
  # => forward lxd port
  config.vm.network "forwarded_port", guest: 8443, host: 8443,auto_correct: true
  # downloading helper executable scripts
  config.vm.provision "shell",privileged:false,name:"utilities", inline: <<-SCRIPT
  [ -r /usr/local/bin/disable-ssh-password-login ] || \
    sudo curl -s \
    -o /usr/local/bin/disable-ssh-password-login \
    #{UTIL_SCRIPTS_BASE_URL}/disable-ssh-password-login && \
    sudo chmod +x /usr/local/bin/disable-ssh-password-login
  [ -r /usr/local/bin/key-get ] || \
    sudo curl -s \
    -o /usr/local/bin/key-get \
    #{UTIL_SCRIPTS_BASE_URL}/key-get && \
    sudo chmod +x /usr/local/bin/key-get
  [ -r /usr/local/bin/lxd-debian ] || \
    sudo curl -s \
    -o /usr/local/bin/lxd-debian \
    #{UTIL_SCRIPTS_BASE_URL}/lxd-debian && \
    sudo chmod +x /usr/local/bin/lxd-debian
  [ -r /usr/local/bin/ngrok-init ] || \
    sudo curl -s \
    -o /usr/local/bin/ngrok-init \
    #{INSTALLER_SCRIPTS_BASE_URL}/ngrok && \
    sudo chmod +x /usr/local/bin/ngrok-init
  SCRIPT
  config.trigger.after [:provision] do |t|
    t.info = "cleaning up after provisioning"
    t.run_remote = {inline: $cleanup_script }
  end
end
