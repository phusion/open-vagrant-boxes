Veewee::Session.declare({
  :cpu_count => '2',
  :memory_size=> '1024',
  :disk_size => '42000',
  :disk_format => 'VDI',
  :hostiocache => 'on',
  :os_type_id => 'Ubuntu_64',
  :iso_file => "ubuntu-12.04.3-server-amd64.iso",
  :iso_src => "http://mirror.anl.gov/pub/ubuntu-iso/DVDs/ubuntu/12.04.3/release/ubuntu-12.04.3-server-amd64.iso",
  :iso_md5 => 'a8c667e871f48f3a662f3fbf1c3ddb17',
  :iso_download_timeout => "1000",
  :boot_wait => "10",
  :boot_cmd_sequence => [
    '<Esc><Esc><Enter>',
    '/install/vmlinuz noapic preseed/url=http://%IP%:%PORT%/preseed.cfg ',
    'debian-installer=en_US auto locale=en_US kbd-chooser/method=us ',
    'hostname=%NAME% ',
    'fb=false debconf/frontend=noninteractive ',
    'keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA keyboard-configuration/variant=USA console-setup/ask_detect=false ',
    'initrd=/install/initrd.gz -- <Enter>'
  ],
  :kickstart_port => "7122",
  :kickstart_timeout => "10000",
  :kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "10000",
  :ssh_user => "vagrant",
  :ssh_password => "vagrant",
  :ssh_key => "../../vagrant_insecure.key",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S bash '%f'",
  :shutdown_cmd => "shutdown -P now",
  :postinstall_files => [
    "base.sh",
    "vagrant.sh",
    "../../iso/_latest_vmware_tools.tar.gz",
    "#{env.current_provider}.sh",
    "chef.sh",
    "puppet.sh",
    "memory_swap_accounting.sh",
    "_cleanup.sh",
    "#{env.current_provider}_cleanup.sh"
  ],
  :postinstall_timeout => "10000",
  :vmfusion => {
    :vm_options => {
      'download_tools' => false
    }
  }
})
