class puppetmaster::profile(
  $master,
  $control_repo,
  $manage_firewall,
) {
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
}
