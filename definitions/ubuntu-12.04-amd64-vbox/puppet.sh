# Install Puppet
set -ex
wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
dpkg -i puppetlabs-release-precise.deb
rm puppetlabs-release-precise.deb
apt-get update
apt-get -y install --no-install-recommends puppet
