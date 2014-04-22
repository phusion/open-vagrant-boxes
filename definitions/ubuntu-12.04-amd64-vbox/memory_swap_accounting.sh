# Enable memory cgroup and swap accounting for Docker.
# http://docs.docker.io/en/latest/installation/kernel/#memory-and-swap-accounting-on-debian-ubuntu
set -ex
sed -i 's/^GRUB_CMDLINE_LINUX=""$/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' /etc/default/grub
update-grub
