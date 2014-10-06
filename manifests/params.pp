class puppetmaster::params {
  $user = 'puppet'
  $group = 'puppet'
  $puppet_root = '/etc/puppet'
  $puppet_usr_root = '/usr/share/puppet'
  $puppet_lib_root = '/var/lib/puppet'
  $master_reports = 'puppetdb'

  case $::osfamily {
    'redhat': {
      $web_group = 'apache'
      $firewall_service = Service['iptables']
      $puppetboard_basedir = '/var/www/html/puppetboard'
    }
    'debian': {
      $web_group = 'www-data'
      $firewall_service = undef
      $puppetboard_basedir = '/var/www/html'
    }
    default:  { fail("osfamily ${::osfamily} is unsupported by class puppetmaster.") }
  }
}
