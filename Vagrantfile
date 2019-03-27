# frozen_string_literal: true

Vagrant.require_version '>= 2.1.2'

Vagrant.configure(2) do |config| # rubocop:disable Metrics/BlockLength
  ram = 1024
  cpu = 1

  guest_port = 3033
  host_port  = 3033
  ip         = '192.168.33.13'

  # Development VM
  config.vm.define 'dev', primary: true do |dev|
    vm = dev.vm

    dev.ssh.forward_agent = true

    vm.provider 'virtualbox' do |v|
      v.memory = ram
      v.cpus   = cpu
    end
    vm.box      = 'ubuntu/bionic64'
    vm.hostname = 'extended-query-postgres-driver'

    vm.network 'private_network', ip: ip
    vm.network 'forwarded_port',  guest: guest_port, host: host_port

    vm.provision :ansible_local do |ansible|
      ansible.provisioning_path = '/vagrant/ansible'
      ansible.playbook          = 'main.yml'
      ansible.inventory_path    = 'inventory/local.ini'
      ansible.limit             = 'local'
      ansible.galaxy_roles_path = 'roles'
      ansible.galaxy_role_file  = 'requirements.yml'
    end
  end

  # Use vagrant-cachier to cache apt-get, gems and other stuff across machines
  config.cache.scope = :box if Vagrant.has_plugin?('vagrant-cachier')
end
