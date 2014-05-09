set -ex

# Remove all kernels
echo "Removing Quantal kernel"
apt-get -y purge linux-generic-lts-quantal linux-generic-lts-quantal-eol-upgrade linux-image-generic-lts-quantal linux-headers-generic-lts-quantal
echo "Removing Raring kernel"
apt-get -y purge linux-generic-lts-raring linux-generic-lts-raring-eol-upgrade linux-image-generic-lts-raring linux-headers-generic-lts-raring
echo "Removing Saucy kernel"
apt-get -y purge linux-generic-lts-saucy linux-generic-lts-saucy-eol-upgrade linux-image-generic-lts-saucy linux-headers-generic-lts-saucy
echo "Removing all kernel images"
dpkg --list | grep linux-image-3. | awk '{ print $2 }' | xargs apt-get -y purge
dpkg --list | grep linux-headers-3. | awk '{ print $2 }' | xargs apt-get -y purge

echo "Installing Trusty kernel"
apt-get -y install linux-generic-lts-trusty linux-headers-generic-lts-trusty
# Install all kernel updates
apt-get -y dist-upgrade

echo "Installed kernels:"
dpkg --list | grep linux-image-3. | awk '{ print $2 }'
echo "Installed kernel headers:"
dpkg --list | grep linux-headers-3. | awk '{ print $2 }'
