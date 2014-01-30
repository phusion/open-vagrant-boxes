BOXES = ['ubuntu-12.04.3-amd64-vbox.box', 'ubuntu-12.04.3-amd64-vmwarefusion.box']
VMWARE_TOOLS_URL = "http://softwareupdate.vmware.com/cds/vmw-desktop/fusion/6.0.2/1398658/packages/com.vmware.fusion.tools.linux.zip.tar"
VMWARE_TOOLS_ARCHIVE = "VMwareTools-9.6.1-1378637.tar.gz"
WEBSERVER = "juvia-helper.phusion.nl"
WEBROOT = "/srv/oss_binaries_passenger/vagrant/boxes"


#### Boxes ####

desc "Build VirtualBox box file"
task "virtualbox:build" do
	sh "bundle exec veewee vbox build ubuntu-12.04.3-amd64-vbox --force --auto"
	sh "bundle exec veewee vbox export ubuntu-12.04.3-amd64-vbox --force"
end

desc "Import VirtualBox box file into Vagrant"
task "virtualbox:import" do
	sh "vagrant box add phusion-open-ubuntu-12.04-amd64 ubuntu-12.04.3-amd64-vbox.box --force"
end


desc "Build VMWare Fusion box file"
task "vmware_fusion:build" => "iso/_latest_vmware_tools.tar.gz" do
	sh "bundle exec veewee fusion build ubuntu-12.04.3-amd64-vmwarefusion --force --auto"
	sh "bundle exec veewee fusion export ubuntu-12.04.3-amd64-vmwarefusion --force"
end

desc "Import VMWare Fusion box file into Vagrant"
task "vmware_fusion:import" do
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
		"unzip com.vmware.fusion.tools.linux.zip"
	sh "cd iso && rm -f manifest.plist descriptor.xml com.vmware.fusion.tools.linux.zip"
	sh "cd iso/payload && 7z x linux.iso && mv #{VMWARE_TOOLS_ARCHIVE} ../"
	sh "rm -rf iso/payload iso/com.vmware.fusion.tools.linux.zip.tar"
end


#### Release #####

desc "Upload boxes to a public server"
task :upload => BOXES do
	BOXES.each do |box|
		sh "ssh", WEBSERVER, "rm -rf #{WEBROOT}/tmp && mkdir #{WEBROOT}/tmp"
		sh "scp", box, "#{WEBSERVER}:#{WEBROOT}/tmp/"
		sh "md5sum #{box} | ssh #{WEBSERVER} tee #{WEBROOT}/tmp/#{box}.md5.txt"
		sh "ssh", WEBSERVER, "mv #{WEBROOT}/tmp/* #{WEBROOT}/ && rm -rf #{WEBROOT}/tmp"
	end
end
