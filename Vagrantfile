# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile for Fleetsuite
#
# Run vagrant up (or vagrant up --provider=vmware_fusion if you're that way inclined)
# Set the host in database.yml to your host machine's IP address.
# Go to /opt/arthurly/fleetsuite and run bundle exec rails server on the remote machine.
# Add a hosts entry on your host machine.
# DONE.
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|


  config.vm.box = 'centos6'
  config.vm.box_url = 'http://mirror.hq.arthurly.net/vagrant/boxes/CentOS-6.4-x86_64-v20130427.box'

  config.vm.provider "vmware_fusion" do |v, override|
    override.vm.box = "centos6_fusion"
    override.vm.box_url = "https://dl.dropbox.com/u/5721940/vagrant-boxes/vagrant-centos-6.4-x86_64-vmware_fusion.box"
  end

  config.vm.network :private_network, ip: '192.168.21.5'
  config.vm.boot_timeout = 60

  # config.vm.forward_port 80, 8080

  config.vm.synced_folder '.', '/opt/arthurly/fleetsuite'

  config.vm.provision :ansible do |ansible|
    ansible.limit = 'all'
    ansible.sudo = true
    ansible.playbook = 'ansible/main.yml'
    ansible.inventory_path = 'dev-hosts.ini'
    ansible.verbose = "v"
  end  

end
