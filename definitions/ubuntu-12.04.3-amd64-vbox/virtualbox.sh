set -ex

# Without libdbus virtualbox would not start automatically after compile
apt-get -y install --no-install-recommends libdbus-1-3

# The netboot installs the VirtualBox support (old) so we have to remove it
set +e
/etc/init.d/virtualbox-ose-guest-utils stop
rmmod vboxguest
set -e
aptitude -y purge virtualbox-ose-guest-x11 virtualbox-ose-guest-dkms virtualbox-ose-guest-utils
aptitude -y install dkms

# Install the VirtualBox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
VBOX_ISO=VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop $VBOX_ISO /mnt
set +e
# It's normal for this to fail because it's unable to install the X drivers.
# By that time the kernel modules have already been installed.
yes|sh /mnt/VBoxLinuxAdditions.run -- install /VBoxLinuxAdditions
set -e
umount /mnt

# Now that the VirtualBox guest additions are installed, we can upgrade the kernel
apt-get -y dist-upgrade
aptitude -y install linux-generic-lts-quantal linux-headers-generic-lts-quantal

#Cleanup VirtualBox
rm $VBOX_ISO
