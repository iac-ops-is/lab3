Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  SERVERS = { "web" => "192.168.56.10", "app" => "192.168.56.11" }
  BRIDGE = "en0: Wi-Fi (Wireless)"

  ssh_key = File.read(File.expand_path("C:\\Users\\maks9\\.ssh\\ansible_key.pub")).strip

  def create_host(config, hostname, ip, ssh_key, setup_script)
    config.vm.define hostname do |host|
      host.vm.network "private_network", ip: ip
      host.vm.network "public_network", bridge: BRIDGE
      host.vm.hostname = hostname
      host.vm.provision "shell", inline: <<-SHELL
        apt-get update && apt-get install -y python3
        mkdir -p /home/vagrant/.ssh
        echo '#{ssh_key}' > /home/vagrant/.ssh/authorized_keys
        chown -R vagrant:vagrant /home/vagrant/.ssh
        chmod 700 /home/vagrant/.ssh
        chmod 600 /home/vagrant/.ssh/authorized_keys
        #{setup_script}
      SHELL
    end
  end

  SERVERS.each do |hostname, ip|
    setup_script = ""
    if hostname == "web"
      setup_script = <<-SCRIPT
        apt-get install -y nginx
        systemctl enable nginx
        systemctl start nginx
      SCRIPT

    elsif hostname == "app"
      setup_script = <<-SCRIPT
        apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
        apt-get update && apt-get install -y docker-ce docker-compose
        systemctl enable docker
        systemctl start docker
      SCRIPT
    end

    create_host(config, hostname, ip, ssh_key, setup_script)
  end
end
