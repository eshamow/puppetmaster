require 'spec_helper'
describe 'puppetmaster' do

  let :facts do
    {
      :operatingsystemrelease => '6.5',
      :operatingsystemmajrelease => '6',
      :osfamily => 'Redhat',
      :architecture => 'x86_64',
      :concat_basedir => '/dne'
    }
  end

  context 'with defaults for all parameters' do
    it 'should warn that two parameters need to be set' do
      expect {
        is_expected.to compile
      }.to raise_error(Puppet::Error, /\$master and \$control_repo must be defined for class puppetmaster./)
    end
  end

  context 'when called' do
    let :params do
      {
        :master => 'localhost',
        :control_repo => 'https://github.com/testrepo/control.git',
        :user => 'puppet',
        :group => 'puppet',
        :web_group => 'apache',
        :puppet_root => '/etc/puppet',
        :puppet_lib_root => '/var/lib/puppet',
        :puppet_usr_root => '/usr/share/puppet'
      }
    end
    it {
      is_expected.to contain_user('puppet').with({'ensure' => 'present', 'groups' => '["apache", "puppet"]'})
      is_expected.to contain_file('/etc/puppet/manifests/site.pp').with('owner' => 'puppet')
      is_expected.to contain_file('/etc/puppet/manifests/site.pp').with_content(/^Package { allow_virtual/)
      is_expected.to contain_file('/etc/puppet/hiera.yaml').with('owner' => 'puppet')
      is_expected.to contain_file('/etc/puppet/hiera.yaml').with_content(/backends:/)
      is_expected.to contain_file('master_hiera').with( {
        'path' => '/etc/puppet/environments/puppet/hieradata/localhost.yaml',
        'owner' => 'puppet',
      })
      is_expected.to contain_file('master_hiera').with_content(/puppetmaster::profile::master: localhost/)
      is_expected.to contain_file('/usr/share/puppet/rack/puppetmasterd/config.ru').with('owner' => 'puppet')
      is_expected.to contain_file('/etc/puppet/environments').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      is_expected.to contain_file('/etc/puppet/environments/puppet').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      is_expected.to contain_file('/etc/puppet/environments/puppet/modules').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      is_expected.to contain_file('/etc/puppet/environments/puppet/hieradata').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      is_expected.to contain_file('/usr/share/puppet/rack').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      is_expected.to contain_file('/usr/share/puppet/rack/puppetmasterd').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      is_expected.to contain_file('/usr/share/puppet/rack/puppetmasterd/public').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      is_expected.to contain_file('/usr/share/puppet/rack/puppetmasterd/tmp').with( {
        'ensure' => 'directory',
        'recurse' => 'true'
      })
      is_expected.to contain_ini_setting('puppetmaster').with( {
        'section' => 'main',
        'setting' => 'server',
        'value' => 'localhost'
      })
      is_expected.to contain_ini_setting('certname').with( {
        'section' => 'main',
        'setting' => 'certname',
        'value' => 'localhost'
      })
      is_expected.to contain_ini_setting('dns_alt_names').with( {
        'section' => 'main',
        'setting' => 'dns_alt_names',
        'value' => 'localhost'
      })
      is_expected.to contain_ini_setting('confdir').with( {
        'section' => 'main',
        'setting' => 'confdir',
        'value' => '/etc/puppet'
      })
      is_expected.to contain_ini_setting('directory_environment_path').with( {
        'section' => 'main',
        'setting' => 'environmentpath',
        'value' => '$confdir/environments'
      })
      is_expected.to contain_ini_setting('directory_environment_manifests').with( {
        'section' => 'main',
        'setting' => 'default_manifest',
        'value' => '$confdir/manifests'
      })
      is_expected.to contain_ini_setting('strict_variable_checking').with( {
        'section' => 'main',
        'setting' => 'strict_variables',
        'value'   => false
      })
      is_expected.to contain_ini_setting('master_reports').with( {
        'section' => 'master',
        'setting' => 'reports',
        'value' => 'puppetdb'
      })
      is_expected.to contain_apache__vhost('localhost').with( {
        'ssl_cert' => '/var/lib/puppet/ssl/certs/localhost.pem',
        'ssl_key' => '/var/lib/puppet/ssl/private_keys/localhost.pem'
      })
      is_expected.to contain_vcsrepo('/etc/puppet/control').with('source' => 'https://github.com/testrepo/control.git')
      is_expected.to contain_class('profile_passenger')
    }
    describe 'with alternate certname' do
      let :params do
        super().merge({
          :certname => 'foo.bar.org'
        })
      end
      it 'should use separate values for master and certname' do
        is_expected.to contain_ini_setting('puppetmaster').with('value' => 'localhost')
        is_expected.to contain_ini_setting('certname').with('value' => 'foo.bar.org')
      end
    end
    describe 'with alternate dns_alt_names' do
      let :params do
        super().merge({
          :dns_alt_names => 'foo.bar.org,puppet'
        })
      end
      it 'should use separate values for master and certname' do
        is_expected.to contain_ini_setting('puppetmaster').with('value' => 'localhost')
        is_expected.to contain_ini_setting('dns_alt_names').with('value' => 'foo.bar.org,puppet')
      end
    end
  end
  context 'when manage_web_stack is set to false' do
    let :params do
      {
        :master => 'localhost',
        :control_repo => 'https://github.com/testrepo/control.git',
        :user => 'puppet',
        :group => 'puppet',
        :web_group => 'apache',
        :puppet_root => '/etc/puppet',
        :puppet_lib_root => '/var/lib/puppet',
        :puppet_usr_root => '/usr/share/puppet',
        :manage_web_stack => false
      }
    end
    it 'should fail to compile' do
      expect {
        is_expected.to compile
      }.to raise_error(Puppet::Error, /Class currently only supports \$manage_web_stack = true/)
    end
  end
end
