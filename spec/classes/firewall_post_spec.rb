require 'spec_helper'
describe 'puppetmaster::firewall::post' do

  context 'when class called' do
    it {
      should contain_firewall('999 drop all').with('action' => 'drop')
    }
  end
end
