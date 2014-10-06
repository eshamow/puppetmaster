class puppetmaster::profile::puppetboard (
  $master    = $puppetmaster::master,
  $basedir   = $puppetmaster::params::puppetboard_basedir,
  $group     = $puppetmaster::group,
  $web_group = $puppetmaster::web_group
) inherits puppetmaster::params {
  class { 'apache::mod::wsgi': }
  class { 'python':
    version    => 'system',
    virtualenv => true,
    dev        => true,
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
}
