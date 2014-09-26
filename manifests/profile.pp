class puppetmaster::profile(
  $master          = undef,
  $control_repo    = undef,
  $manage_firewall = true,
) {
  if ($master == undef) or ($control_repo == undef) {
    fail('$master and $control_repo must be defined for profile puppetmaster.')
  }
  if $manage_firewall {
    Firewall {
      before  => Class['puppetmaster::firewall::post'],
      require => Class['puppetmaster::firewall::pre'],
    }
    resources { 'firewall':
      purge => true
    }
    class { ['puppetmaster::firewall::pre', 'puppetmaster::firewall::post']: }
    class { 'puppetmaster::firewall':
      before => Service['iptables'],
    }
    class { '::firewall': }
  }
  class { 'puppetmaster':
    master       => $master,
    control_repo => $control_repo,
  }
  class { 'epel': }
  class { 'puppetdb':
    listen_address     => $master,
    ssl_listen_address => $master,
  }
  class { 'puppetdb::master::config':
    puppet_service_name => 'httpd',
    puppetdb_server     => $master,
  }
  class { 'r10k':
    version                => $r10k_version,
    sources                => {
      'puppet' => {
        'remote'  => $control_repo,
        'basedir' => "${::settings::confdir}/environments",
        'prefix'  => false,
      }
    },
    purgedirs              => ["${::settings::confdir}/environments"],
    install_options        => '--debug',
    manage_modulepath      => false,
    manage_ruby_dependency => ignore,
  }
}
