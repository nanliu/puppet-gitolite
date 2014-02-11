require 'beaker-rspec'

hosts.each do |host|
  # Install Puppet
  install_pe
  on master, shell('iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport 8140 -j ACCEPT'), { :acceptable_exit_codes => [0,1] }
  #install_package host, 'rubygems'
  #on host, 'gem install puppet --no-ri --no-rdoc'
  on host, "mkdir -p #{host['distmoduledir']}"
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'gitolite')
    on master, shell('/opt/puppet/bin/puppet module install puppetlabs-vcsrepo --version 0.2.0'), { :acceptable_exit_codes => [0,1] }
    on master, shell('/opt/puppet/bin/puppet module install puppetlabs-git --version 0.0.3'), { :acceptable_exit_codes => [0,1] }
    on master, shell('/opt/puppet/bin/puppet module install nanliu-staging --version 0.3.1'), { :acceptable_exit_codes => [0,1] }
    hosts.each do |host|
      # Required for binding tests.
      if fact('osfamily') == 'RedHat'
        version = fact("operatingsystemmajrelease")
#        shell("rpm -i http://yum.puppetlabs.com/puppetlabs-release-el-#{version}.noarch.rpm")
      end

#      shell('/bin/touch /etc/puppet/hiera.yaml')
      shell('puppet module install puppetlabs-stdlib --version 3.2.0', { :acceptable_exit_codes => [0,1] })
    end
  end
end
