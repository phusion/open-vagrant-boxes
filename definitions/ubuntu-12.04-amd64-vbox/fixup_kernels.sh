set -ex

# Remove kernels < 3.8 because they don't work well with Docker.
echo "Removing Saucy kernel"
apt-get -y purge linux-generic-lts-saucy linux-image-generic-lts-saucy linux-headers-generic-lts-saucy

# Remove all kernels > 3.8 because VMWare Tools (and possibly older
# VirtualBox guest additions) don't work on them.
kernels=`dpkg --list | grep linux-image-3. | awk '{ print $2 }'`
echo "Installed kernels:"
echo "$kernels"
for kernel in $kernels; do
	minor_version=`echo "$kernel" | sed 's/^linux-image-//; s/-.*//' | cut -d. -f2`
	if [[ "$minor_version" -gt 8 ]]; then
		echo "Removing kernel $kernel"
		apt-get -y purge "$kernel"
	fi
done

# Install kernel 3.8 and all kernel updates.
echo "Installing Raring kernel"
apt-get -y install linux-generic-lts-raring linux-headers-generic-lts-raring
apt-get -y dist-upgrade
