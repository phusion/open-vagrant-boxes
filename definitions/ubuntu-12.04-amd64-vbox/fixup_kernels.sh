# Remove all kernels > 3.8 because VMWare Tools (and possibly older
# VirtualBox guest additions) don't work on them.
set -e

echo "Removing Saucy kernel"
apt-get -y purge linux-generic-lts-saucy linux-headers-generic-lts-saucy

kernels=`dpkg --list | grep linux-image-3. | awk '{ print $2 }'`
for kernel in $kernels; do
	minor_version=`echo "$kernel" | sed 's/^linux-image-//; s/-.*//' | cut -d. -f2`
	if [[ "$minor_version" -gt 8 ]]; then
		echo "Removing kernel $kernel"
		apt-get -y purge "$kernel"
	fi
done

echo "Installing Raring kernel"
apt-get -y install linux-generic-lts-raring linux-headers-generic-lts-raring
