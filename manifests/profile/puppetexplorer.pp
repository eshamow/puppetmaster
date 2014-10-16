class puppetmaster::profile::explorer (
  $manage_firewall = true,
) inherits puppetmaster::params {
  class { '::puppetexplorer':
  class { 'puppetmaster::firewall::puppetboard':
    before  => Class['puppetmaster::firewall::post'],
    require => Class['puppetmaster::firewall::pre'],
  }
}
