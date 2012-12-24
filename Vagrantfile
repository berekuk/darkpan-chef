#-*- mode: ruby -*-
# vi: set ft=ruby :

# See the online documentation at vagrantup.com for a reference on this file format.
Vagrant::Config.run do |config|

  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Uncomment this option to start VM with a GUI, if you run in a serious trouble.
  # config.vm.boot_mode = :gui

  # Production and dev http ports.
  config.vm.forward_port 9200, 9200

  # Enable and configure the chef solo provisioner
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = 'cookbooks'
    chef.add_recipe 'darkpan'
  end

end
