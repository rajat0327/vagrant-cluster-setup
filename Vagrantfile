Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.boot_timeout = 300

  NODES = [
    { name: "master-1", ip: "192.168.56.11", cpus: 2, memory: 2048 },
    { name: "worker-1", ip: "192.168.56.12", cpus: 2, memory: 2048 },
    { name: "worker-2", ip: "192.168.56.13", cpus: 2, memory: 2048 }
  ]

  NODES.each do |node|
    config.vm.define node[:name] do |node_config|
      node_config.vm.hostname = node[:name]
      node_config.vm.network "private_network", ip: node[:ip]

      node_config.vm.provider "virtualbox" do |vb|
        vb.name = node[:name]
        vb.cpus = node[:cpus]
        vb.memory = node[:memory]
      end

      # Copy your public key to the VM (for rajat user later)
      pubkey_path = File.expand_path("~/.ssh/id_rsa.pub")
      if File.exist?(pubkey_path)
        node_config.vm.provision "file", source: pubkey_path, destination: "/home/vagrant/id_rsa.pub"
      end

      # Provisioning script
      node_config.vm.provision "shell", inline: <<-SHELL
        # Create 'rajat' user if it doesn't exist
        if ! id -u rajat >/dev/null 2>&1; then
          sudo adduser --disabled-password --gecos "" --shell /bin/bash rajat
          echo 'rajat ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/rajat
        fi

        # Setup SSH for 'rajat'
        if [ -f /home/vagrant/id_rsa.pub ]; then
          mkdir -p /home/rajat/.ssh
          cat /home/vagrant/id_rsa.pub >> /home/rajat/.ssh/authorized_keys
          chown -R rajat:rajat /home/rajat/.ssh
          chmod 700 /home/rajat/.ssh
          chmod 600 /home/rajat/.ssh/authorized_keys
        fi

        # Add all node IPs to /etc/hosts
        echo "
192.168.56.11 master-1
192.168.56.12 worker-1
192.168.56.13 worker-2
          " | sudo tee -a /etc/hosts
      SHELL
    end
  end
end
