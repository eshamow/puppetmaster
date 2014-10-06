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
# === Examples
#
# See README.md for full instructions.
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
  $user             = $puppetmaster::params::user,
  $group            = $puppetmaster::params::group,
  $web_group        = $puppetmaster::params::web_group,
  $puppet_root      = $puppetmaster::params::puppet_root,
  $puppet_lib_root  = $puppetmaster::params::puppet_lib_root,
  $puppet_usr_root  = $puppetmaster::params::puppet_usr_root,
) inherits puppetmaster::params {
  if ($master == undef) or ($control_repo == undef) {
    fail('$master and $control_repo must be defined for class puppetmaster.')
  }
  user { $user:
    ensure => present,
    groups => [$web_group,$group],
  }
  file { "${puppet_root}/manifests/site.pp":
    ensure  => file,
    content => template('puppetmaster/site.pp.erb'),
    owner   => $user,
    group   => $group,
    mode    => '0740',
  }
  file { "${puppet_root}/hiera.yaml":
    ensure  => file,
    content => template('puppetmaster/hiera.yaml.erb'),
    owner   => $user,
    group   => $group,
    mode    => '0740',
  }
  file { ["${puppet_root}/environments",
          "${puppet_root}/environments/puppet",
          "${puppet_root}/environments/puppet/modules",
          "${puppet_root}/environments/puppet/hieradata"]:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0740',
    recurse => true,
  }
  file { 'master_hiera':
    ensure  => file,
    path    => "${puppet_root}/environments/puppet/hieradata/${certname}.yaml",
    content => template('puppetmaster/master.yaml.erb'),
    owner   => $user,
    group   => $web_group,
    mode    => '0740',
  }
  file { ["${puppet_usr_root}/rack",
          "${puppet_usr_root}/rack/puppetmasterd",
          "${puppet_usr_root}/rack/puppetmasterd/public",
          "${puppet_usr_root}/rack/puppetmasterd/tmp"]:
    ensure  => directory,
    owner   => $user,
    group   => $web_group,
    mode    => '0740',
    recurse => true,
  }
  file { "${puppet_usr_root}/rack/puppetmasterd/config.ru":
    ensure => file,
    source => "${puppet_usr_root}/ext/rack/config.ru",
    owner  => $user,
    group  => $group,
    mode   => '0740',
  }

  Ini_setting {
    ensure  => present,
    path    => "${puppet_root}/puppet.conf",
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
    value   => $puppet_root,
  }
  ini_setting { 'directory_environment_path':
    setting => 'environmentpath',
    value   => '$confdir/environments',
  }
  ini_setting { 'directory_environment_manifests':
    setting => 'default_manifest',
    value   => '$confdir/manifests',
  }
  ini_setting { 'puppetdb_reports':
    setting => 'reports',
    value   => 'puppetdb',
    section => 'master'
  }
  if $manage_web_stack {
    contain profile_passenger
  } else {
    fail('Class currently only supports $manage_web_stack = true')
  }

  apache::vhost { $master:
    port                 => '8140',
    ssl                  => true,
    ssl_protocol         => 'ALL -SSLv2 -SSLv3',
    ssl_cipher           => 'EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA',
    ssl_honorcipherorder => 'on',
    ssl_cert             => "${puppet_lib_root}/ssl/certs/${master}.pem",
    ssl_key              => "${puppet_lib_root}/ssl/private_keys/${master}.pem",
    ssl_chain            => "${puppet_lib_root}/ssl/ca/ca_crt.pem",
    ssl_ca               => "${puppet_lib_root}/ssl/ca/ca_crt.pem",
    ssl_crl              => "${puppet_lib_root}/ssl/ca/ca_crl.pem",
    ssl_verify_client    => 'optional',
    ssl_verify_depth     => '1',
    ssl_options          => ['+StdEnvVars', '+ExportCertData'],
    request_headers      => [
      'set X-SSL-Subject %{SSL_CLIENT_S_DN}e',
      'set X-Client-DN %{SSL_CLIENT_S_DN}e',
      'set X-Client-Verify %{SSL_CLIENT_VERIFY}e',
    ],
    docroot              => "${puppet_usr_root}/rack/puppetmasterd/public",
    directories          => [
      { path            => "${puppet_usr_root}/rack/puppetmasterd/",
        'Options'       => 'None',
        'AllowOverride' => 'None',
        'Order'         => 'allow,deny',
        'Allow'         => 'from all',
      },
    ],
  }
  vcsrepo { "${puppet_root}/control":
    ensure   => present,
    provider => git,
    source   => $control_repo,
  }
}
