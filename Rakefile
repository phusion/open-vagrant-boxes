# We do not use 6.0.2 because of a HGFS bug:
# https://communities.vmware.com/thread/462303
VMWARE_TOOLS_URL = "https://softwareupdate.vmware.com/cds/vmw-desktop/fusion/6.0.3/1747349/packages/com.vmware.fusion.tools.linux.zip.tar"
VMWARE_TOOLS_ARCHIVE = "VMwareTools-9.6.2-1688356.tar.gz"
VERSION = "2014-04-22"
WEBSERVER = "juvia-helper.phusion.nl"
WEBROOT = "/srv/oss_binaries_passenger/vagrant/boxes/#{VERSION}"

require 'tmpdir'


#### Boxes ####

desc "Build VirtualBox box file & import it into Vagrant"
task "virtualbox:all" => ["virtualbox:build_image", "virtualbox:fixup_image",
	"virtualbox:build_box", "virtualbox:import_box"]

desc "Build VirtualBox image"
task "virtualbox:build_image" do
	sh "bundle exec veewee vbox build ubuntu-12.04.3-amd64-vbox --force --auto"
	sh "bundle exec veewee vbox ssh ubuntu-12.04.3-amd64-vbox 'sudo poweroff'"
	puts "Sleeping a few seconds, waiting for the VM to power off."
	sh "sleep 30"
end

desc "Fix up VirtualBox Guest Additions inside the VM"
task "virtualbox:fixup_image" do
	# After building the box, the kernel has been upgraded. We boot into
	# the new kernel to install VirtualBox Guest Additions.
	sh "bundle exec veewee vbox up ubuntu-12.04.3-amd64-vbox"
	sh "sleep 10"
	sh "chmod 600 vagrant_insecure.key"
	command = "cd /home/vagrant && " +
		"bash /home/vagrant/_virtualbox.sh && " +
		"bash /home/vagrant/_cleanup.sh virtualbox && " +
		"poweroff"
	command = "sudo bash -c #{Shellwords.escape command}"
	sh "bundle exec veewee vbox ssh ubuntu-12.04.3-amd64-vbox #{Shellwords.escape command}"
	puts "Sleeping a few seconds, waiting for the VM to power off."
	sh "sleep 10"
end

desc "Build VirtualBox box file"
task "virtualbox:build_box" do
	require 'nokogiri'
	sh "bundle exec veewee vbox export ubuntu-12.04.3-amd64-vbox --force"
	sh "rm -rf tmp && mkdir tmp && cd tmp && tar xf ../ubuntu-12.04.3-amd64-vbox.box"
	doc = Nokogiri.XML(File.open("tmp/box.ovf", "r"))
	# Remove DVD device which could cause problems for older VirtualBoxes:
	# https://github.com/phusion/open-vagrant-boxes/issues/1
	(doc / "StorageControllers > StorageController[name='IDE Controller'] > AttachedDevice[port='1']").remove
	# Remove all Shared Folders created by Veewee, since they reference
	# directories that will not exist on machines other than the builder's.
	# This removes some warnings.
	(doc / "SharedFolder").remove
	File.open("tmp/box.ovf", "w") do |f|
		doc.write_xml_to(f)
	end
	sh "cd tmp && tar -cf ../ubuntu-12.04.3-amd64-vbox.box *"
	sh "rm -rf tmp"
end

desc "Import VirtualBox box file into Vagrant"
task "virtualbox:import_box" do
	sh "vagrant box add phusion-open-ubuntu-12.04-amd64 ubuntu-12.04.3-amd64-vbox.box --force"
end


desc "Build VMWare Fusion box file & import it into Vagrant"
task "vmware_fusion:all" => ["vmware_fusion:build_image", "vmware_fusion:fixup_image",
	"vmware_fusion:build_box", "vmware_fusion:import_box"]

desc "Build VMWare Fusion image"
task "vmware_fusion:build_image" => "iso/_latest_vmware_tools.tar.gz" do
	sh "bundle exec veewee fusion build ubuntu-12.04.3-amd64-vmwarefusion --force --auto"
	sh "bundle exec veewee fusion ssh ubuntu-12.04.3-amd64-vmwarefusion 'sudo poweroff'"
	puts "Sleeping a few seconds, waiting for the VM to power off."
	sh "sleep 30"
end

desc "Fix up VMWare Tools inside the VM"
task "vmware_fusion:fixup_image" do
	# After building the box, the kernel has been upgraded. We have to boot it
	# in the new kernel at least once so that the VMWare Tools are properly compiled
	# for the new kernel.
	sh "bundle exec veewee fusion up ubuntu-12.04.3-amd64-vmwarefusion"
	sh "sleep 10"
	sh "chmod 600 vagrant_insecure.key"
	command = "cd /home/vagrant && " +
		"bash /home/vagrant/_vmfusion.sh && " +
		"bash /home/vagrant/_cleanup.sh vmfusion && " +
		"poweroff"
	command = "sudo bash -c #{Shellwords.escape command}"
	sh "bundle exec veewee fusion ssh ubuntu-12.04.3-amd64-vmwarefusion #{Shellwords.escape command}"
	puts "Sleeping a few seconds, waiting for the VM to power off."
	sh "sleep 10"
end

desc "Build VMWare Fusion box file"
task "vmware_fusion:build_box" do
	sh "bundle exec veewee fusion export ubuntu-12.04.3-amd64-vmwarefusion --force"
	Dir.mktmpdir('vmfusion', Dir.pwd) do |tmpdir|
		puts "Temp dir #{tmpdir} created"
		sh "cd #{tmpdir} && tar xzf ../ubuntu-12.04.3-amd64-vmwarefusion.box"
		vmx = Dir["#{tmpdir}/*.vmx"].first
		puts "Disabling VMWare Tools autoupdate in #{vmx}"
		contents = File.open(vmx, "r") { |f| f.read }
		contents.sub!(/^tools\.upgrade\.policy = .*$/, '')
		contents << "\ntools.upgrade.policy = \"manual\"\n"
		File.open(vmx, "w") { |f| f.write(contents) }
		sh "cd #{tmpdir} && env GZIP=--best tar -czf ../ubuntu-12.04.3-amd64-vmwarefusion.box *"
	end
end

desc "Import VMWare Fusion box file into Vagrant"
task "vmware_fusion:import_box" do
	sh "vagrant box add phusion-open-ubuntu-12.04-amd64 ubuntu-12.04.3-amd64-vmwarefusion.box --force"
end


#### VMWare Tools ####
# We're not sure whether it's allowed to redistribute the VMWare Tools,
# and the open-vm-tools on Ubuntu 12.04 are too old to be compatible with
# kernel 3.8, so we download the latest VMWare Tools.

file "iso/_latest_vmware_tools.tar.gz" => "iso/#{VMWARE_TOOLS_ARCHIVE}" do
	sh "cp iso/#{VMWARE_TOOLS_ARCHIVE} iso/_latest_vmware_tools.tar.gz"
end

file "iso/#{VMWARE_TOOLS_ARCHIVE}" do
	sh "mkdir -p iso"
	sh "cd iso && curl -L -O -# --fail -S #{VMWARE_TOOLS_URL}"
	sh "cd iso && " +
		"tar xf com.vmware.fusion.tools.linux.zip.tar && " +
		"unzip -o com.vmware.fusion.tools.linux.zip"
	sh "cd iso && rm -f manifest.plist descriptor.xml com.vmware.fusion.tools.linux.zip"
	sh "cd iso/payload && 7z x linux.iso && mv #{VMWARE_TOOLS_ARCHIVE} ../"
	sh "rm -rf iso/payload iso/com.vmware.fusion.tools.linux.zip.tar"
end


#### Release #####

def create_release_task(name, box_file)
	desc "Release #{name} box file to a public server"
	task "release:#{name}" => box_file do
		sh "ssh", WEBSERVER, "mkdir -p #{WEBROOT} && rm -rf #{WEBROOT}/tmp && mkdir #{WEBROOT}/tmp"
		sh "scp #{box_file} #{WEBSERVER}:#{WEBROOT}/tmp/"
		sh "md5sum #{box_file} | ssh #{WEBSERVER} tee #{WEBROOT}/tmp/#{box_file}.md5.txt"
		sh "ssh", WEBSERVER, "mv #{WEBROOT}/tmp/* #{WEBROOT}/ && rm -rf #{WEBROOT}/tmp"
	end
end

desc "Release all box files to a public server"
task "release" => ["release:virtualbox", "release:vmware_fusion"]

create_release_task("virtualbox", "ubuntu-12.04.3-amd64-vbox.box")
create_release_task("vmware_fusion", "ubuntu-12.04.3-amd64-vmwarefusion.box")
