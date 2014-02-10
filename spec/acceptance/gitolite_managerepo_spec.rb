require 'spec_helper_acceptance'

describe 'gitolite' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'gitolite':
          key_user => 'testuser',
          pubkey => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxc6YHP7wMBdqZKniQDnLtGKH8eE1PwbWDoNZWIGxRVGNpfztSrIF6tFyNMOIWYI++2++UsupZovEcw9aL0w6zEeYB2PHrfPj+B2DtdaR0jRCI9LhW9WdHPICOtpf3Sz7wJWBzUN/8+mGdBscqDBY+6piCr+IBlmGKy5OEbim2V59qFDdBpBGtgMVMNV+r4J8i9aPGkjVd8+sY1yjt9qSL00FqtWbd0Gdd281+2pUxm4xBBX3pItnoYyLeJQdiEAGHoUtyaZZqxLaXicJJmADNHERhfCbXoT/krQ5XcUiMCRS18Y2ibbCc7IKVgEZXX8xB8kUK+Ox46Y8Y1kzR4qjR eric@rassilon.corp.puppetlabs.net',
        }
      EOS

      # Run class twice and check for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end
end
