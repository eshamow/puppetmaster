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
    puppetdb_host => $master,
    puppetdb_port => '8081',
    puppetdb_key  => '/etc/puppetdb/ssl/private.pem',
    puppetdb_ssl  => '/etc/puppetdb/ssl/ca.pem',
    puppetdb_cert => '/etc/puppetdb/ssl/public.pem',
  }
  class { 'puppetboard::apache::conf': }
}
