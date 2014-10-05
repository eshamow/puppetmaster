class puppetmaster::profile::puppetboard (
  $master = $puppetmaster::master,
  $basedir = $puppetmaster::params::puppetboard_basedir
) inherits puppetmaster::params {
  class { 'apache::mod::wsgi': }
  class { 'python':
    virtualenv => true,
    dev        => true,
  } ->
  class { '::puppetboard':
    manage_virtualenv => false,
    puppetdb_host => 'localhost',
    puppetdb_port => '8081',
    puppetdb_key  => "/var/lib/puppet/ssl/private_keys/${::certname}.pem",
    puppetdb_ssl  => "'/var/lib/puppet/ssl/certs/ca.pem'",
    puppetdb_cert => "/var/lib/puppet/ssl/certs/${::certname}.pem",
  }
  class { 'puppetboard::apache::conf': }
}
