set -ex

date > /etc/vagrant_box_build_time

# Setup sudo to allow no-password sudo for "sudo"
usermod -a -G sudo vagrant

# Set root password
echo 'root:vagrant' | chpasswd

# Installing vagrant keys
mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

mkdir -p /root/.ssh
chmod 700 /root/.ssh
cp /home/vagrant/.ssh/authorized_keys /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
chown root:root /root/.ssh/authorized_keys
