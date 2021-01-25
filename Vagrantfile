# -*- mode: ruby -*-
# vi: set ft=ruby :
# [ NOTE ] => ref
#   - https://gist.github.com/swalkinshaw/5266b6869fcbbedf074d
#   - https://stackoverflow.com/a/46626430
# [ NOTE ] => Usage : 
# vagrant up ubuntu --provider libvirt
synced_folder  = ENV[     'SYNCED_FOLDER'      ]  || "/home/vagrant/#{File.basename(Dir.pwd)}"
memory         = ENV[           'MEMORY'       ]  || 4096
cpus           = ENV[           'CPUS'         ]  || 4
vm_name        = ENV[           'VM_NAME'      ]  || File.basename(Dir.pwd)
forwarded_ports= [8443]
provisioners   = [
  "node",
  "python",
  "starship",
  "nu",
  "spacevim",
  "ripgrep",
  "docker",
  "lxd",
  # "pandoc",
  # "goenv",
  # "hashicorp",
]
utility_scripts= [
  "disable-ssh-password-login",
  "clean-pkgs",
  "key-get",
  "lxd-debian",
  "ngrok-init"
]
INSTALLER_SCRIPTS_BASE      = "https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/installer"
UTIL_SCRIPTS_BASE           = "https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/util"
Vagrant.configure("2") do |config|
  config.vm.define "ubuntu" do |box| box.vm.box="generic/ubuntu2010" end
  config.vm.define "debian" do |box| box.vm.box="generic/debian10" end
  config.vm.define "arch" do |box| box.vm.box="generic/arch" end
  config.vm.define "#{vm_name}"
  config.vm.hostname = "#{vm_name}"
  config.vm.synced_folder ".","#{synced_folder}",auto_correct:true, owner: "vagrant",group: "vagrant",disabled:true
  config.vagrant.plugins = [ "vagrant-vbguest" ]
  config.vm.box = "generic/debian10"
  config.vm.provider "virtualbox" do |vb, override|
    vb.memory = "#{memory}"
    vb.cpus   = "#{cpus}"
    # => enable nested virtualization
    vb.customize ["modifyvm",:id,"--nested-hw-virt", "on"]    
    override.vm.synced_folder ".", "#{synced_folder}",disabled: false,
      auto_correct:true, owner: "vagrant",group: "vagrant",type: "virtualbox"
  end
  # [ WARN ] => avoid hyper-v if you can. It is the worst hypervisor that I have worked with.
  # it has horerendous memory/cpu management. it makes my on my surface book 3 ( 32 GB RAM ) model , which is 
  # the flagship Microsoft laptop, slow as hell.
  # [ REF ] => https://docs.microsoft.com/en-us/virtualization/community/team-blog/2017/20170706-vagrant-and-hyper-v-tips-and-tricks
  config.vm.provider "hyperv" do |h,override|
    h.enable_virtualization_extensions = true
    h.linked_clone = true
    h.cpus   = "#{cpus}"
    # [ NOTE ] => https://github.com/hashicorp/vagrant/issues/10349#issuecomment-435185440
    h.memory = "#{memory}"
    h.maxmemory = "#{memory}"
    override.vm.network "public_network"
    override.vm.synced_folder ".", "#{synced_folder}",disabled: false,auto_correct:true, type: "smb",
    owner: "vagrant",group: "vagrant"
  end
  # [ NOTE ] => use libvirt for the most optimized experience
  # [ NOTE ] => use vagrant ( vagrant plugin install vagrant-libvirt )
  # to install libvirt provider rather than package manager
  # (sudo apt-get install vagrant-libvirt) to get the latest version.
  config.vm.provider "libvirt" do |libvirt,override|
    libvirt.memory = "#{memory}"
    libvirt.cpus = "#{cpus}"
    libvirt.nested = true
    libvirt.cpu_mode = "host-passthrough"
    # [ NOTE ] => https://askubuntu.com/questions/772784/9p-libvirt-qemu-share-modes
    # [ NOTE ] => ensuring vagrant user owns the folder
    override.vm.synced_folder ".", "#{synced_folder}", 
      disabled: false,auto_correct:true, owner: "1000", group: "1000",
      type: "9p",  accessmode: "squash" 
    if ! Vagrant::Util::Platform.windows?
      override.trigger.before [:resume,:up,:reload] do |t|
        t.info = "Ensuring the directory is world-writable so that guest can write in it."
        t.run = {inline: "sudo chmod 777 #{ENV["PWD"]} -R"}
      end
      override.trigger.before [:suspend,:halt,:destroy] do |t|
        t.info = "Returning ownership of synced directory directory back to '#{ENV["USER"]}''"
        t.run = {inline: "sudo chown '#{ENV["USER"]}:#{ENV["GROUP"]}' #{ENV["PWD"]} -R"}
      end
      override.trigger.before [:suspend,:halt,:destroy] do |t|
        t.info = "making sure synced directory is not world writable"
        t.run = {inline: "sudo chmod 775 #{ENV["PWD"]} -R"}
      end
    end
  end if Vagrant.has_plugin?('vagrant-libvirt')
  forwarded_ports.each do |port|
    config.vm.network "forwarded_port", 
      guest: port, 
      host: port,
      auto_correct: true
  end
  config.vm.provision "shell",
    privileged:false,
    name:"cleanup", 
    path: "#{UTIL_SCRIPTS_BASE}/clean-pkgs"
  config.vm.provision "shell",
    privileged:false,
    name:"init",
    path: "#{INSTALLER_SCRIPTS_BASE}/init"
  # [ NOTE ] => downloading helper executable scripts
  utility_scripts.each do |utility|
    config.vm.provision "shell",
      privileged:false,
      name:"#{utility}-utility-script",
      inline: <<-SCRIPT
    [ -r /usr/local/bin/#{utility} ] || \
      sudo curl -s \
      -o /usr/local/bin/#{utility} \
      #{UTIL_SCRIPTS_BASE}/#{utility} && \
      sudo chmod +x /usr/local/bin/#{utility}
    SCRIPT
  end
  # [ NOTE ] => provisioning
  provisioners.each do |provisioner|
    config.vm.provision "shell",
      privileged:false,
      name:"#{provisioner}",
      path: "#{INSTALLER_SCRIPTS_BASE}/#{provisioner}"
  end
  config.trigger.after [:provision] do |t|
    t.info = "cleaning up after provisioning"
    t.run_remote = {path: "#{UTIL_SCRIPTS_BASE}/clean-pkgs" }
  end
end
