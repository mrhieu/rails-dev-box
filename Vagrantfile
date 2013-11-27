Vagrant.configure('2') do |config|
  config.vm.box      = 'precise32'
  config.vm.box_url  = 'http://files.vagrantup.com/precise32.box'
  config.vm.hostname = 'rails-dev-box'

  config.vm.network :forwarded_port, guest: 3000, host: 3000

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'puppet/manifests'
    puppet.module_path    = 'puppet/modules'
  end

  config.vm.provider "virtualbox" do |v|
	  v.customize ["modifyvm", :id, "--cpuexecutioncap", "80"]
	  v.customize ["modifyvm", :id, "--memory", "4000"]
	end
end
