require 'spec_helper'
describe 'puppetmaster::firewall' do

  context 'when class called' do
    it {
      should contain_firewall('100 allow ssh access').with('port' => '22')
      should contain_firewall('200 allow puppetdb access').with('port' => '8081')
      should contain_firewall('250 allow puppet access').with('port' => '8140')
      should contain_firewall('300 allow mco access').with('port' => '61613')
    }
  end
end
