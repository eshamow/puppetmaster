# == Class: puppetmaster
#
# Full description of class puppetmaster here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'puppetmaster':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class puppetmaster( $master = undef ) {
  if $master == undef {
    fail('$master must be defined for class puppetmaster.')
  }

  Package { allow_virtual => false }

  user { 'puppet':
    ensure => present,
    groups => ['apache','puppet'],
  }
  file { '/etc/puppet/manifests/site.pp':
    ensure => file,
    content => template('puppetmaster/site.pp.erb'),
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0740',
  }
  package { 'ruby-devel':
    ensure => installed,
  } ->
  package { 'rubygems':
    ensure => installed,
  } ->
  class { 'apache': } ->
  class { 'gcc': } ->
  class { 'passenger': }

  file { ['/usr/share/puppet/rack',
          '/usr/share/puppet/rack/puppetmasterd',
          '/usr/share/puppet/rack/puppetmasterd/public',
          '/usr/share/puppet/rack/puppetmasterd/tmp']:
    ensure  => directory,
    owner   => 'puppet',
    group   => 'apache',
    mode    => '0740',
    recurse => true,
    require => Class['passenger'],
  }

  file { '/usr/share/puppet/rack/puppetmasterd/config.ru':
    ensure => file,
    source => '/usr/share/puppet/ext/rack/config.ru',
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0740',
  }
  apache::vhost { "${master}":
    port => '8140',
    ssl  => true,
    ssl_protocol => 'ALL -SSLv2 -SSLv3',
    ssl_cipher   => 'EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA',
    ssl_honorcipherorder => 'on',
    ssl_cert => "/var/lib/puppet/ssl/certs/${master}.pem",
    ssl_key  => "/var/lib/puppet/ssl/private_keys/${master}.pem",
    ssl_chain => '/var/lib/puppet/ssl/ca/ca_crt.pem',
    ssl_ca    => '/var/lib/puppet/ssl/ca/ca_crt.pem',
    ssl_crl => '/var/lib/puppet/ssl/ca/ca_crl.pem',
    ssl_verify_client => 'optional',
    ssl_verify_depth  => '1',
    ssl_options => ['+StdEnvVars', '+ExportCertData'],
    request_headers => [
      'set X-SSL-Subject %{SSL_CLIENT_S_DN}e',
      'set X-Client-DN %{SSL_CLIENT_S_DN}e',
      'set X-Client-Verify %{SSL_CLIENT_VERIFY}e',
    ],
    docroot  => '/usr/share/puppet/rack/puppetmasterd/public',
    directories => [
      { path => '/usr/share/puppet/rack/puppetmasterd/',
        'Options' => 'None',
        'AllowOverride' => 'None',
        'Order' => 'allow,deny',
        'Allow' => 'from all',
      },
    ],
  }
}