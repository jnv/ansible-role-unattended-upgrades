# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "debian" do |debian|
    debian.vm.box = "chef/debian-7.4"
  end

  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "ubuntu/trusty64"
  end

  config.vm.provision :shell, inline: "sudo apt-get install -y python python-apt aptitude"
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "role.yml"
    ansible.verbose = "vv"
    ansible.sudo = true
  end
end
