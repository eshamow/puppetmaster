class puppetmaster::profile::puppetexplorer (
  $manage_firewall = true,
) inherits puppetmaster::params {
  class { '::puppetexplorer': }
  class { 'puppetmaster::firewall::puppetexplorer':
    before  => Class['puppetmaster::firewall::post'],
    require => Class['puppetmaster::firewall::pre'],
  }
}
