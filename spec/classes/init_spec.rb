require 'spec_helper'
describe 'puppetmaster' do

  context 'with defaults for all parameters' do
    it 'should warn that two parameters need to be set' do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /\$master and \$control_repo must be defined for class puppetmaster./)
    end
  end

  context 'when passed minimimum default values' do
    let :params do
      {
        :master => 'localhost',
        :control_repo => 'https://github.com/testrepo/control.git'
      }
    end
    let :facts do
      {
        :operatingsystemrelease => '6.5',
        :operatingsystemmajrelease => '6',
        :osfamily => 'Redhat',
        :architecture => 'x86_64',
        :concat_basedir => '/dne'
      }
    end
    it {
      should contain_user('puppet').with({'ensure' => 'present', 'groups' => '["apache", "puppet"]'})
      should contain_file('/etc/puppet/manifests/site.pp').with('owner' => 'puppet')
      should contain_file('/etc/puppet/manifests/site.pp').with_content(/^Package { allow_virtual/)
      should contain_file('/etc/puppet/hiera.yaml').with('owner' => 'puppet')
      should contain_file('/etc/puppet/hiera.yaml').with_content(/backends:/)
      should contain_file('master_hiera').with( {
        'path' => '/etc/puppet/environments/puppet/hieradata/localhost.yaml',
        'owner' => 'puppet',
      })
      should contain_file('master_hiera').with_content(/puppetmaster::profile::master: localhost/)
      should contain_file('/usr/share/puppet/rack/puppetmasterd/config.ru').with('owner' => 'puppet')
      should contain_file('/etc/puppet/environments').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      should contain_file('/etc/puppet/environments/puppet').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      should contain_file('/etc/puppet/environments/puppet/modules').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      should contain_file('/etc/puppet/environments/puppet/hieradata').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      should contain_file('/usr/share/puppet/rack').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      should contain_file('/usr/share/puppet/rack/puppetmasterd').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      should contain_file('/usr/share/puppet/rack/puppetmasterd/public').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      should contain_file('/usr/share/puppet/rack/puppetmasterd/tmp').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      should contain_ini_setting('puppetmaster').with( {
        'section' => 'main',
        'setting' => 'server',
        'value' => 'localhost'
      })
      should contain_ini_setting('certname').with( {
        'section' => 'main',
        'setting' => 'certname',
        'value' => 'localhost'
      })
      should contain_ini_setting('dns_alt_names').with( {
        'section' => 'main',
        'setting' => 'dns_alt_names',
        'value' => 'localhost'
      })
      should contain_ini_setting('confdir').with( {
        'section' => 'main',
        'setting' => 'confdir',
        'value' => '/etc/puppet'
      })
      should contain_ini_setting('directory_environment_path').with( {
        'section' => 'main',
        'setting' => 'environmentpath',
        'value' => '$confdir/environments'
      })
      should contain_ini_setting('directory_environment_manifests').with( {
        'section' => 'main',
        'setting' => 'default_manifest',
        'value' => '$confdir/manifests'
      })
    }
  end
end
