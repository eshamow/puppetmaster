# == Class: puppetmaster
#
# Installs a standalone puppet master and r10k.
#
# === Parameters
#
# [*master*]
#   DNS name for puppet master. Mandatory. Defaults to undef.
#
# [*control_repo*]
#   URL of control repository. Mandatory. Defaults to undef.
#
# [*certname*]
#   certname to be assigned to puppet master. Defaults to $master
#
# [*dns_alt_names*]
#   Comma-separated list of alternate DNS names for the puppet master cert.
#   Defaults to $master
#
# [*manage_web_stack*]
#   Install profile_passenger module, enabling Apache and Passenger configs.
#   Defaults to true.
#
# [*manage_firewall*]
#   Manage firewall ports using puppetlabs-firewall module. Defaults to true.
#
# [*hiera_enc*]
#   Use a hiera_include based ENC. If set to false, another node terminus must
#   be selected. Defaults to true.
#
# [*r10k_version*]
#
#   r10k version to be installed. Defaults to 'installed'.
#
# === Examples
#
# When used via puppet apply to bootstrap installation:
#
# puppet apply --modulepath /etc/puppet/environments/puppet/modules --verbose -e 'class { "puppetmaster": master => "master", control_repo => "https://github.com/myuser/mycontrolrepo.git" }'
#
# An example of effective usage in a profile can be found in puppetmaster::profile
#
# === Authors
#
# Eric Shamow <eric.shamow@gmail.com>
#
# === Copyright
#
# Copyright 2014 Eric Shamow
#
class puppetmaster(
  $master           = undef,
  $control_repo     = undef,
  $certname         = $master,
  $dns_alt_names    = $master,
  $manage_web_stack = true,
  $manage_firewall  = true,
  $hiera_enc        = true,
  $r10k_version     = 'installed'
) {
  if ($master == undef) or ($control_repo == undef) {
    fail('$master and $control_repo must be defined for class puppetmaster.')
  }
  user { 'puppet':
    ensure => present,
    groups => ['apache','puppet'],
  }
  file { '/etc/puppet/manifests/site.pp':
    ensure  => file,
    content => template('puppetmaster/site.pp.erb'),
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0740',
  }
  file { '/etc/puppet/hiera.yaml':
    ensure  => file,
    content => template('puppetmaster/hiera.yaml.erb'),
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0740',
  }
  file { ['/etc/puppet/environments',
          '/etc/puppet/environments/puppet',
          '/etc/puppet/environments/puppet/modules',
          '/etc/puppet/environments/puppet/hieradata']:
    ensure  => directory,
    owner   => 'puppet',
    group   => 'apache',
    mode    => '0740',
    recurse => true,
  }
  file { 'master_hiera':
    ensure  => file,
    path    => "/etc/puppet/environments/puppet/hieradata/${certname}.yaml",
    content => template('puppetmaster/master.yaml.erb'),
    owner   => 'puppet',
    group   => 'apache',
    mode    => '0740',
  }
  file { ['/usr/share/puppet/rack',
          '/usr/share/puppet/rack/puppetmasterd',
          '/usr/share/puppet/rack/puppetmasterd/public',
          '/usr/share/puppet/rack/puppetmasterd/tmp']:
    ensure  => directory,
    owner   => 'puppet',
    group   => 'apache',
    mode    => '0740',
    recurse => true,
  }
  file { '/usr/share/puppet/rack/puppetmasterd/config.ru':
    ensure => file,
    source => '/usr/share/puppet/ext/rack/config.ru',
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0740',
  }

  Ini_setting {
    ensure  => present,
    path    => '/etc/puppet/puppet.conf',
    section => 'main',
  }
  ini_setting { 'puppetmaster':
    setting => 'server',
    value   => $master,
  }
  ini_setting { 'certname':
    setting => 'certname',
    value   => $certname,
  }
  ini_setting { 'dns_alt_names':
    setting => 'dns_alt_names',
    value   => $dns_alt_names,
  }
  ini_setting { 'confdir':
    setting => 'confdir',
    value   => '/etc/puppet',
  }
  ini_setting { 'directory_environment_path':
    setting => 'environmentpath',
    value   => '$confdir/environments',
  }
  ini_setting { 'directory_environment_manifests':
    setting => 'default_manifest',
    value   => '$confdir/manifests',
  }
  if $manage_web_stack {
    contain profile_passenger
  }
  apache::vhost { $master:
    port                 => '8140',
    ssl                  => true,
    ssl_protocol         => 'ALL -SSLv2 -SSLv3',
    ssl_cipher           => 'EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA',
    ssl_honorcipherorder => 'on',
    ssl_cert             => "/var/lib/puppet/ssl/certs/${master}.pem",
    ssl_key              => "/var/lib/puppet/ssl/private_keys/${master}.pem",
    ssl_chain            => '/var/lib/puppet/ssl/ca/ca_crt.pem',
    ssl_ca               => '/var/lib/puppet/ssl/ca/ca_crt.pem',
    ssl_crl              => '/var/lib/puppet/ssl/ca/ca_crl.pem',
    ssl_verify_client    => 'optional',
    ssl_verify_depth     => '1',
    ssl_options          => ['+StdEnvVars', '+ExportCertData'],
    request_headers      => [
      'set X-SSL-Subject %{SSL_CLIENT_S_DN}e',
      'set X-Client-DN %{SSL_CLIENT_S_DN}e',
      'set X-Client-Verify %{SSL_CLIENT_VERIFY}e',
    ],
    docroot              => '/usr/share/puppet/rack/puppetmasterd/public',
    directories          => [
      { path            => '/usr/share/puppet/rack/puppetmasterd/',
        'Options'       => 'None',
        'AllowOverride' => 'None',
        'Order'         => 'allow,deny',
        'Allow'         => 'from all',
      },
    ],
  }
  vcsrepo { '/etc/puppet/control':
    ensure   => present,
    provider => git,
    source   => $control_repo,
  }
}
