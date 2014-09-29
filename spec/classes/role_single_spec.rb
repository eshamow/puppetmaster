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

  let :params do
    {
      :master => 'localhost',
      :control_repo => 'https://github.com/youruser/control.git'
    }
  end
  it do
    should contain_class('puppetmaster::profile')
  end
end
