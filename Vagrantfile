# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'getoptlong'
require 'ostruct'
# [ NOTE ] => Usage : 
# vagrant --synced-folder="/home/vagrant/$(basename "$PWD")" --no-goenv --no-hashicorp --ubuntu up
# [ NOTE ] => https://github.com/EA31337/EA-Tester/blob/master/Vagrantfile
# [ NOTE ] => https://rosettacode.org/wiki/Parse_command-line_arguments#Ruby_with_.27getoptlong.27
opts = GetoptLong.new(
  [ '--ubuntu',             GetoptLong::NO_ARGUMENT ],
  [ '--debian',             GetoptLong::NO_ARGUMENT ],
  [ '--arch',               GetoptLong::NO_ARGUMENT ],
  [ '--no-node',            GetoptLong::NO_ARGUMENT ],
  [ '--no-python',          GetoptLong::NO_ARGUMENT ],
  [ '--no-starship',        GetoptLong::NO_ARGUMENT ],
  [ '--no-nu',              GetoptLong::NO_ARGUMENT ],
  [ '--no-goenv',           GetoptLong::NO_ARGUMENT ],
  [ '--no-spacevim',        GetoptLong::NO_ARGUMENT ],
  [ '--no-hashicorp',       GetoptLong::NO_ARGUMENT ],
  [ '--no-ripgrep',         GetoptLong::NO_ARGUMENT ],
  [ '--no-docker',          GetoptLong::NO_ARGUMENT ],
  [ '--no-lxd',             GetoptLong::NO_ARGUMENT ],
  [ '--vm-name',            GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--synced-folder',      GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--memory',             GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--cpus',               GetoptLong::OPTIONAL_ARGUMENT ],
)
box            = ENV[           'BOX'          ]
memory         = ENV[           'MEMORY'       ]  || 4096
cpus           = ENV[           'CPUS'         ]  || 4
vm_name        = ENV[           'VM_NAME'      ]  || File.basename(Dir.pwd)
provider       = ENV['VAGRANT_DEFAULT_PROVIDER']  || 'virtualbox'
forwarded_ports= [8443]
provisioners   = ["node","python","starship","nu","goenv","spacevim","hashicorp","ripgrep","docker","lxd"]
utility_scripts= ["disable-ssh-password-login","clean-pkgs","key-get","lxd-debian","ngrok-init"]
synced_folder  = OpenStruct.new
begin
  opts.each do |opt, arg|
    case opt
      when '--ubuntu';        box = "generic/ubuntu2010"
      when '--debian';        box = "generic/debian10"
      when '--arch';          box = "generic/arch"
      when '--vm-name';       vm_name = arg
      when '--synced-folder'; synced_folder.path = arg
      when '--memory';        memory = arg.to_i
      when '--cpus';          cpus  = arg.to_i
      when '--no-nu';         provisioners.delete("nu") 
      when '--no-goenv';      provisioners.delete("goenv") 
      when '--no-spacevim';   provisioners.delete("spacevim") 
      when '--no-hashicorp';  provisioners.delete("hashicorp") 
      when '--no-ripgrep';    provisioners.delete("ripgrep") 
      when '--no-docker';     provisioners.delete("docker") 
      when '--no-lxd';      
        provisioners.delete("lxc")
        forwarded_ports.delete(8443)
      when '--no-starship'; provisioners.delete("starship") 
      when '--no-node'
        provisioners.delete("node")
        provisioners.delete("spacevim")
      when '--no-python'
        provisioners.delete("python")
        provisioners.delete("spacevim") 
    end
  end
rescue
end
box                             = "generic/debian10" if box.nil? || box.empty?
synced_folder.path              = "/vagrant/#{File.basename(Dir.pwd)}" if synced_folder.path.nil? || synced_folder.path.empty?
case provider
  when 'virtualbox';
    (vagrant_plugins ||= []) << "vagrant-vbguest"
    synced_folder.type = "virtualbox"
end
ENV['VAGRANT_DEFAULT_PROVIDER'] = provider
INSTALLER_SCRIPTS_BASE      = "https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/installer"
UTIL_SCRIPTS_BASE           = "https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/util"
# require 'optparse'

# options = {}
# OptionParser.new do |opts|
#   opts.banner = "Usage: example.rb [options]"

#   opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
#     options[:verbose] = v
#   end
# end.parse!

# p options
# p ARGV
# p "Where is my hat?!" if ARGV.length == 0

Vagrant.configure("2") do |config|
  config.vagrant.plugins=vagrant_plugins
  config.vm.define "#{vm_name}"
  config.vm.hostname = "#{vm_name}"
  if synced_folder.type.nil? || synced_folder.type.empty?
    config.vm.synced_folder ".", "#{synced_folder.path}",auto_correct:true, owner: "vagrant",group: "vagrant"
  else 
    config.vm.synced_folder ".", "#{synced_folder.path}",auto_correct:true, owner: "vagrant",group: "vagrant",type:"#{synced_folder.type}"
  end
  config.vm.box = "#{box}"
  config.vm.provider "virtualbox" do |vb, override|
    vb.memory = "#{memory}"
    vb.cpus   = "#{cpus}"
    # => enable nested virtualization
    vb.customize ["modifyvm",:id,"--nested-hw-virt", "on"]    
  end
  forwarded_ports.each do |port|
    config.vm.network "forwarded_port", guest: port, host: port,auto_correct: true
  end
  config.vm.provision "shell",privileged:false,name:"cleanup", path: "#{UTIL_SCRIPTS_BASE}/clean-pkgs"
  config.vm.provision "shell",privileged:false,name:"init", path: "#{INSTALLER_SCRIPTS_BASE}/init"
  # [ NOTE ] => downloading helper executable scripts
  utility_scripts.each do |utility|
    config.vm.provision "shell",privileged:false,name:"#{utility}-utility-script", inline: <<-SCRIPT
    [ -r /usr/local/bin/#{utility} ] || \
      sudo curl -s \
      -o /usr/local/bin/#{utility} \
      #{UTIL_SCRIPTS_BASE}/#{utility} && \
      sudo chmod +x /usr/local/bin/#{utility}
    SCRIPT
  end
  # [ NOTE ] => provisioning
  provisioners.each do |provisioner|
    config.vm.provision "shell",privileged:false,name:"#{provisioner}", path: "#{INSTALLER_SCRIPTS_BASE}/#{provisioner}"
  end
  config.trigger.after [:provision] do |t|
    t.info = "cleaning up after provisioning"
    t.run_remote = {path: "#{UTIL_SCRIPTS_BASE}/clean-pkgs" }
  end
end