require 'spec_helper'
describe 'puppetmaster::profile::puppetboard' do

  let :facts do
    {
      :operatingsystemrelease => '6.5',
      :operatingsystemmajrelease => '6',
      :osfamily => 'RedHat',
      :architecture => 'x86_64',
      :concat_basedir => '/dne'
    }
  end

  context 'when passed minimimum default values' do
    let :params do
      {
        :master    => 'localhost',
        :basedir   => '/www',
        :group     => 'puppet',
        :web_group => 'apache'
      }
    end
    it {
      should contain_class('apache::mod::wsgi')
      should contain_class('python').with({
        'version' => 'system',
        'virtualenv' => 'true',
        'dev' => 'true'
      })
      should contain_class('puppetboard').with({
        'manage_virtualenv' => 'false',
        'groups'            => ['puppet','apache'],
        'puppetdb_host'     => 'localhost',
        'puppetdb_port'     => '8081',
        'puppetdb_key'      => '/var/lib/puppet/ssl/private_keys/localhost.pem',
        'puppetdb_ssl_verify' => '/var/lib/puppet/ssl/certs/ca.pem',
        'puppetdb_cert'       => '/var/lib/puppet/ssl/certs/localhost.pem'
      })
      should contain_class('puppetboard::apache::conf')
    }
  end
end
