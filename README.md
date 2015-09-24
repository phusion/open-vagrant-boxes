# Docker-friendly Vagrant base boxes

<img src="http://blog.phusion.nl/wp-content/uploads/2013/11/vagrant.png" height="150">
<img src="http://blog.phusion.nl/wp-content/uploads/2013/11/docker.png" height="150">

This repository contains definitions for various Docker-friendly [Vagrant](http://www.vagrantup.com/) base boxes. There are boxes that are based on Ubuntu 12.04 64-bit, and boxes that are based on Ubuntu 14.04 64-bit. They differ from the ones provided by vagrantup.com in the following ways:

 * We provide 2 virtual CPUs by default, so that the boxes can make better use of multicore hosts.
 * We provide more RAM by default: 1 GB.
 * We provide a bigger virtual hard disk: around 40 GB.
 * We use LVM so that partitioning is easier.
 * On the Ubuntu 12.04 version, our default kernel version is 3.13 (instead of 3.2), so that you can use [Docker](http://www.docker.io/) out-of-the-box.
 * [The memory cgroup and swap accounting](http://docs.docker.io/en/latest/installation/ubuntulinux/#memory-and-swap-accounting) are turned on, for some Docker features.
 * Chef is installed via the Ubuntu packages that they provide, instead of via RubyGems. This way the box doesn't have to come with Ruby by default, making the environment cleaner.
 * Our VMWare Fusion boxes recompile VMWare Tools on every kernel upgrade, so that Shared Folders keep working even if you change the kernel.

These base boxes are automatically built from [Veewee](https://github.com/jedi4ever/veewee) definitions. These definitions make building boxes quick and unambigious. The entire building process is described in the definitions; no manual intervention is required.

We provide prebuilt boxes at https://oss-binaries.phusionpassenger.com/vagrant/boxes/, but you can build them yourself if you so wish.

The boxes are also available on [Vagrant Cloud](https://vagrantcloud.com/phusion).

**Related resources**:
 [Github](https://github.com/phusion/open-vagrant-boxes) |
 [Prebuilt boxes](https://oss-binaries.phusionpassenger.com/vagrant/boxes/) |
 [Vagrant Cloud](https://vagrantcloud.com/phusion) |
 [Discussion forum](https://groups.google.com/forum/#!forum/passenger-docker) |
 [Twitter](https://twitter.com/phusion_nl) |
 [Blog](http://blog.phusion.nl)

## Using these boxes in Vagrant

If you have Vagrant 1.5, you can use our boxes through [Vagrant Cloud](https://vagrantcloud.com/phusion):

    vagrant init phusion/ubuntu-14.04-amd64
    # -OR-
    vagrant init phusion/ubuntu-12.04-amd64

On older Vagrant versions, you can modify your Vagrantfile to use our boxes. Here is an example Vagrantfile which works with both VirtualBox and VMWare Fusion. It also automatically installs the latest version of Docker.

    # Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
    VAGRANTFILE_API_VERSION = "2"

    Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
      config.vm.box = "phusion-open-ubuntu-14.04-amd64"
      config.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box"
      # Or, for Ubuntu 12.04:
      #config.vm.box = "phusion-open-ubuntu-12.04-amd64"
      #config.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-12.04-amd64-vbox.box"

      config.vm.provider :vmware_fusion do |f, override|
        override.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vmwarefusion.box"
        #override.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-12.04-amd64-vmwarefusion.box"
      end

      # Only run the provisioning on the first 'vagrant up'
      if Dir.glob("#{File.dirname(__FILE__)}/.vagrant/machines/default/*/id").empty?
        # Install Docker
        pkg_cmd = "wget -q -O - https://get.docker.io/gpg | apt-key add -;" \
          "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list;" \
          "apt-get update -qq; apt-get install -q -y --force-yes lxc-docker; "
        # Add vagrant user to the docker group
        pkg_cmd << "usermod -a -G docker vagrant; "
        config.vm.provision :shell, :inline => pkg_cmd
      end
    end

You can login with username `vagrant` and password `vagrant`. This user has sudo privileges. The root user also has password `vagrant`.

The prebuilt boxes are available at https://oss-binaries.phusionpassenger.com/vagrant/boxes/

## Next steps

[<img src="http://www.phusion.nl/assets/logo.png">](http://www.phusion.nl/)

These Vagrant boxes are provided to you by [Phusion](http://www.phusion.nl/). You may want to check out these too:

 * [Discussion forum](https://groups.google.com/forum/#!forum/passenger-docker) - For discussions about this project.
 * [Phusion Passenger](https://www.phusionpassenger.com/) - A fast, robust application server for Ruby, Python, Node.js, and Meteor.
 * [baseimage-docker](https://github.com/phusion/baseimage-docker) - A minimal Ubuntu Docker base image modified for Docker-friendliness.
 * [The Phusion blog](http://blog.phusion.nl) - For interesting articles and updates.
 * [Follow us on Twitter](https://twitter.com/phusion_nl)

## Building the boxes yourself

### Setup your environment

 1. Install [Vagrant](http://www.vagrantup.com/).
 2. Install [VirtualBox](https://www.virtualbox.org/) or VMWare Fusion.
 3. Install 7-zip (OS X: `brew install p7zip`).
 4. `bundle install --path vendor`

    The `--path` is important! Not installing with `--path` will break Vagrant.

### Building a box and importing it into Vagrant

VirtualBox:

    bundle exec rake virtualbox:ubuntu-14.04-amd64:all
    bundle exec rake virtualbox:ubuntu-12.04-amd64:all

VMWare Fusion:

    bundle exec rake vmware_fusion:ubuntu-14.04-amd64:all
    bundle exec rake vmware_fusion:ubuntu-12.04-amd64:all
