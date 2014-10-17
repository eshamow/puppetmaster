class puppetmaster::profile::puppetexplorer (
  $master          = $puppetmaster::master
  $manage_firewall = true,
) inherits puppetmaster::params {
  class { '::puppetexplorer':
    servername => $master
    proxy_pass => [{ 'path' => '/api/v4','url' => "http://${master}:8080/v4" }]
  }
  class { 'puppetmaster::firewall::puppetexplorer':
    before  => Class['puppetmaster::firewall::post'],
    require => Class['puppetmaster::firewall::pre'],
  }
}
