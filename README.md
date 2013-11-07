This repository contains definitions for the Phusion [Vagrant](http://www.vagrantup.com/) base boxes. Definitions are created using [Veewee](https://github.com/jedi4ever/veewee).

These definitions makes building boxes quick and unambigious. The entire building process is described in the definitions; no manual intervention is required.

Phusion's boxes differ from the ones provided in by vagrantup.com in the following ways:

 * We provide a bigger virtual hard disk: around 40 GB.
 * We use LVM so that partitioning is easier.
 * Our default kernel version is 3.8, so that it's easy to use [Docker](http://www.docker.io/).

Prebuilt boxes are available at https://oss-binaries.phusionpassenger.com/vagrant/boxes/

## Environment setup

 1. Install [Vagrant](http://www.vagrantup.com/).
 2. Install [VirtualBox](https://www.virtualbox.org/) or VMWare Fusion.
 3. `bundle install --path vendor`

    The `--path` is important! Not installing with `--path` will break Vagrant.

## Building a box and importing it into Vagrant

VirtualBox:

    bundle exec rake virtualbox

VMWare Fusion:

    bundle exec rake vmware_fusion

## Login

You can login with username `vagrant` and password `vagrant`. This user has sudo privileges. The root user also has password `vagrant`.
