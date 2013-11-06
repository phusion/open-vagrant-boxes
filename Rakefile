BOXES = ['ubuntu-12.04.3-amd64-vbox.box', 'ubuntu-12.04.3-amd64-vmwarefusion.box']
WEBSERVER = "juvia-helper.phusion.nl"
WEBROOT = "/srv/oss_binaries_passenger/vagrant/boxes"

desc "Build VirtualBox box & import into Vagrant"
task :virtualbox => 'ubuntu-12.04.3-amd64-vbox.box' do
	sh "vagrant box add phusion-ubuntu-12.04-amd64 ubuntu-12.04.3-amd64-vbox.box --force"
end

desc "Build VirtualBox box"
file 'ubuntu-12.04.3-amd64-vbox.box' => Dir["definitions/ubuntu-12.04.3-amd64-vbox/*"] do
	sh "bundle exec veewee vbox build ubuntu-12.04.3-amd64-vbox --force"
	sh "bundle exec veewee vbox export ubuntu-12.04.3-amd64-vbox --force"
end

desc "Build VMWare Fusion box & import into Vagrant"
task :vmware_fusion => 'ubuntu-12.04.3-amd64-vmwarefusion.box' do
	sh "vagrant box add phusion-ubuntu-12.04-amd64 ubuntu-12.04.3-amd64-vmwarefusion.box --force"
end

desc "Build VMWare Fusion box"
file 'ubuntu-12.04.3-amd64-vmwarefusion.box' => Dir["definitions/ubuntu-12.04.3-amd64-vmwarefusion/*"] do
	sh "bundle exec veewee fusion build ubuntu-12.04.3-amd64-vmwarefusion --force"
	sh "bundle exec veewee fusion export ubuntu-12.04.3-amd64-vmwarefusion --force"
end

desc "Upload boxes to a public server"
task :upload => BOXES do
	BOXES.each do |box|
		sh "ssh", WEBSERVER, "rm -rf #{WEBROOT}/tmp && mkdir #{WEBROOT}/tmp"
		sh "scp", box, "#{WEBSERVER}:#{WEBROOT}/tmp/"
		sh "md5sum #{box} | ssh #{WEBSERVER} tee #{WEBROOT}/tmp/#{box}.md5.txt"
		sh "ssh", WEBSERVER, "mv #{WEBROOT}/tmp/* #{WEBROOT}/ && rm -rf #{WEBROOT}/tmp"
	end
end
