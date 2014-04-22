# Remove items used for building, since they aren't needed anymore.
set -ex

if [[ "$1" = vmfusion ]]; then
	while ! modprobe vmhgfs; do
		echo "`date`: VMWare Tools not yet compiled. Waiting..." 
		sleep 5
	done
	echo "`date`: VMWare Tools are now compiled. Proceeding with cleanup in a few seconds."
	sleep 5
fi

apt-get remove -y build-essential
apt-get -y autoremove
apt-get clean

# Clean up tmp
rm -rf /tmp/*

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm -f /var/lib/dhcp/*

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm -f /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces

rm -f /home/vagrant/*.sh
rm -f /home/vagrant/*.gz
rm -f /home/vagrant/*.iso
rm -f /home/vagrant/_*

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY
dd if=/dev/zero of=/boot/EMPTY bs=1M || true
rm -f /boot/EMPTY
sync
