# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "debian7" do |debian|
    debian.vm.box = "debian/wheezy64"
  end

  config.vm.define "debian8" do |debian|
    debian.vm.box = "debian/jessie64"
  end

  config.vm.define "ubuntu1204" do |ubuntu|
    ubuntu.vm.box = "ubuntu/precise64"
  end

  config.vm.define "ubuntu1404" do |ubuntu|
    ubuntu.vm.box = "ubuntu/trusty64"
  end

  config.vm.define "ubuntu1604" do |ubuntu|
    ubuntu.vm.box = "ubuntu/xenial64"
  end

  config.vm.provision :shell, inline: "sudo apt-get install -y python python-apt aptitude"
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "role.yml"
    ansible.verbose = "vv"
    ansible.sudo = true
  end
end
