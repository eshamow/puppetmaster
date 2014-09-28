require 'spec_helper'
describe 'puppetmaster::firewall::pre' do

  context 'when class called' do
    it {
      should contain_firewall('000 accept all icmp').with({
        'proto' => 'icmp',
        'action' => 'accept'
      })
      should contain_firewall('001 accept all to lo interface').with({
        'iniface' => 'lo',
        'action' => 'accept'
      })
      should contain_firewall('002 accept related established rules').with({
        'proto' => 'all',
        'state' => ["RELATED","ESTABLISHED"],
        'action' => 'accept'
      })
    }
  end
end
