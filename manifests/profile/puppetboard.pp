class puppetmaster::profile::puppetboard (
  $manage_firewall = true,
  $master          = $puppetmaster::master,
  $basedir         = $puppetmaster::params::puppetboard_basedir,
  $group           = $puppetmaster::group,
  $web_group       = $puppetmaster::web_group
) inherits puppetmaster::params {
  class { 'apache::mod::wsgi': }
  class { 'python':
    version    => 'system',
    pip        => true,
    virtualenv => true,
    dev        => true,
    require    => Class['epel'],
  } ->
  class { '::puppetboard':
    manage_virtualenv   => false,
    groups              => [$group,$web_group],
    puppetdb_host       => $master,
    puppetdb_port       => '8081',
    puppetdb_key        => "/var/lib/puppet/ssl/private_keys/${master}.pem",
    puppetdb_ssl_verify => '/var/lib/puppet/ssl/certs/ca.pem',
    puppetdb_cert       => "/var/lib/puppet/ssl/certs/${master}.pem",
  }
  class { 'puppetboard::apache::conf': }
  class { 'puppetmaster::firewall::puppetboard':
    before  => Class['puppetmaster::firewall::post'],
    require => Class['puppetmaster::firewall::pre'],
  }
}
