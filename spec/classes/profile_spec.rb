require 'spec_helper'
describe 'puppetmaster::profile' do

  let :facts do
    {
      :operatingsystemrelease => '6.5',
      :operatingsystemmajrelease => '6',
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat',
      :architecture => 'x86_64',
      :kernel => 'Linux',
      :concat_basedir => '/dne'
    }
  end

  context 'with defaults for all parameters' do
    it 'should warn that two parameters need to be set' do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /\$master and \$control_repo must be defined for profile puppetmaster./)
    end
  end

  context 'when passed minimimum default values' do
    let :params do
      {
        :master => 'localhost',
        :control_repo => 'https://github.com/testrepo/control.git'
      }
    end
    it {
      should contain_class('puppetmaster').with({
        'master' => 'localhost',
        'control_repo' => 'https://github.com/testrepo/control.git'
      })
      should contain_class('epel')
      should contain_class('puppetdb').with({
        'listen_address' => 'localhost',
        'ssl_listen_address' => 'localhost'
      })
      should contain_class('puppetdb::master::config').with({
        'puppet_service_name' => 'httpd',
        'puppetdb_server' => 'localhost'
      })
      should contain_class('r10k').with({
        'version' => 'installed',
        'sources' => {
          'puppet' => {
            'remote' => 'https://github.com/testrepo/control.git',
            'basedir' => '/etc/puppet/environments',
            'prefix' => false
          }
        }
      })
      should contain_class('puppetmaster::firewall::pre')
      should contain_class('puppetmaster::firewall::post')
      should contain_class('firewall')
      should contain_class('puppetmaster::firewall').with('before' => 'Service[iptables]')
    }
  end
  context 'on debian-based systems' do
    let :facts do
      {
        :operatingsystemrelease => '7.6',
        :operatingsystemmajrelease => '7',
        :osfamily => 'Debian',
        :operatingsystem => 'Debian',
        :architecture => 'x86_64',
        :kernel => 'Linux',
        :concat_basedir => '/dne'
      }
    end
    let :params do
      {
        :master => 'localhost',
        :control_repo => 'https://github.com/testrepo/control.git'
      }
    end
    it {
      should contain_class('puppetmaster::firewall').without('before' => 'Service[iptables]')
    }
  end

  context 'when $manage_firewall is set to false' do
    let :params do
      {
        :master => 'localhost',
        :control_repo => 'https://github.com/testrepo/control.git',
        :manage_firewall => false
      }
    end
    it {
      should_not contain_class('puppetmaster::firewall')
      should_not contain_class('puppetmaster::firewall::pre')
      should_not contain_class('puppetmaster::firewall::post')
      should_not contain_class('firewall')
    }
  end
  context 'when custom r10k version is passed' do
    let :params do
      {
        :master => 'localhost',
        :control_repo => 'https://github.com/testrepo/control.git',
        :r10k_version => '1.3.4'
      }
    end
    it {
      should contain_class('r10k').with({'version' => '1.3.4'})
    }
  end
end
