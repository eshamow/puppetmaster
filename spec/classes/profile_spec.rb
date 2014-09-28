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
    }
  end
end
