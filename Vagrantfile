# -*- mode: ruby -*-
# vi: set ft=ruby :

module OS
  def OS.windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end
  def OS.mac?
      (/darwin/ =~ RUBY_PLATFORM) != nil
  end
  def OS.unix?
      !OS.windows?
  end
  def OS.linux?
      OS.unix? and not OS.mac?
  end
end
# [NOTE] => avoid hyper-v like plague. It's a trash hypervisor. 
#if OS.windows?
#  default_provider = ENV['VAGRANT_DEFAULT_PROVIDER'] || 'hyperv'
#else
 default_provider = ENV['VAGRANT_DEFAULT_PROVIDER'] || 'virtualbox'
#end
ENV['VAGRANT_DEFAULT_PROVIDER'] = default_provider
NAME=ENV["VAGRANT_MACHINE_NAME"] || File.basename(Dir.pwd)
MEMORY_LIMIT=ENV["MEMORY_LIMIT"] || 4096
CORE_LIMIT=ENV["CORE_LIMIT"] || 4
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
  config.vm.define "#{NAME}"
  config.vm.hostname = "#{NAME}"
  config.vagrant.plugins=["vagrant-vbguest","vagrant-rsync-back"]
  config.vm.synced_folder ".", "/vagrant/#{NAME}", disabled: true,auto_correct:true
  # in case you can't get nested virtualization working for virtualbox, refer to guide in this link
  # https://answers.microsoft.com/en-us/surface/forum/all/how-to-enable-vt-x-on-surface-book-3/b9057c59-eb8a-4221-85c4-90a3d44edd55
  config.vm.provider "virtualbox" do |vb, override|
    vb.memory = "#{MEMORY_LIMIT}"
    vb.cpus   = "#{CORE_LIMIT}"
    # => enable nested virtualization
    vb.customize [
                  "modifyvm",:id,
                  "--nested-hw-virt", "off",
                  # "--paravirtprovider", "kvm",
                ]    
    override.vm.box = "generic/debian10"
    override.vm.synced_folder ".", "/vagrant/#{NAME}", owner: "vagrant",group: "vagrant", type: "virtualbox"
    override.vm.provision "shell",privileged:false,name:"docker", path: "https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/installer/docker"
    override.vm.provision "shell",privileged:false,name:"lxd", path: "https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/installer/lxd"
    # => forward lxd port
    override.vm.network "forwarded_port", guest: 8443, host: 8443,auto_correct: true
  end
  # [WARN] => avoid hyper-v if you can. It is the worst hypervisor that I have worked with.
  # it has horerendous memory/cpu management. it makes my on my surface book 3 ( 32 GB RAM ) model , which is 
  # the flagship Microsoft laptop, slow as hell.
  # [REF] => https://docs.microsoft.com/en-us/virtualization/community/team-blog/2017/20170706-vagrant-and-hyper-v-tips-and-tricks
  config.vm.provider "hyperv" do |h,override|
    h.enable_virtualization_extensions = true
    h.linked_clone = true
    h.cpus   = "#{CORE_LIMIT}"
    # [NOTE] => https://github.com/hashicorp/vagrant/issues/10349#issuecomment-435185440
    h.memory = "#{MEMORY_LIMIT}"
    h.maxmemory = "#{MEMORY_LIMIT}"
    override.vm.box = "generic/debian10"
    override.vm.network "public_network"
    override.vm.synced_folder ".", "/vagrant/#{NAME}", type: "smb",
    owner: "vagrant",group: "vagrant"
    override.vm.provision "shell",privileged:false,name:"docker", path: "https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/installer/docker"
    override.vm.provision "shell",privileged:false,name:"lxd", path: "https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/installer/lxd"
    override.vm.network "forwarded_port", guest: 8443, host: 8443,auto_correct: true
  end
  config.vm.provider 'docker' do |d, override|
    # d.remains_running = true
    d.name = "#{NAME}"
    d.build_dir = 'contrib/vagrant/docker'
    d.has_ssh = true
    d.env = {
      :SSH_USER => 'vagrant',
      :SSH_SUDO => 'ALL=(ALL) NOPASSWD:ALL',
      :LANG     => 'en_US.UTF-8',
      :LANGUAGE => 'en_US:en',
      :LC_ALL   => 'en_US.UTF-8',
      :SSH_INHERIT_ENVIRONMENT => 'true',
    }
    d.create_args = ["--privileged"]
    d.create_args = ["--cpuset-cpus=#{CORE_LIMIT}"]
    d.create_args = ["--memory=#{MEMORY_LIMIT}m"]
    d.volumes=[
      "./:/vagrant/#{NAME}:z",
      # [NOTE] => removes '.vagrant' and '.git' from container
      "vagrant:/vagrant/#{NAME}/.vagrant",
      "git:/vagrant/#{NAME}/.git",
    ]
    if ! OS.windows?
      override.trigger.after [:resume,:up,:reload] do |t|
        t.info = "Taking ownership of /vagrant directory in the container"
        t.run_remote = {inline: "sudo chown 'vagrant:vagrant' /vagrant -R"}
      end
      override.trigger.before [:suspend,:halt,:destroy] do |t|
        t.info = "Returning ownership of /vagrant directory back to '#{ENV["USER"]}''"
        t.run = {inline: "sudo chown '#{ENV["USER"]}:#{ENV["USER"]}' #{ENV["PWD"]} -R"}
      end
    end
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
  # downloading helper executable scripts
  config.vm.provision "shell",privileged:false,name:"cleanup", inline: <<-SCRIPT
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