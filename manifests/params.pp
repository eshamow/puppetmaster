class puppetmaster::params {
  $user = 'puppet'
  $group = 'puppet'
  $puppet_root = '/etc/puppet'
  $puppet_usr_root = '/usr/share/puppet'
  $puppet_lib_root = '/var/lib/puppet'

  case $::osfamily {
    'redhat': { $web_group = 'apache' }
    'debian': { $web_group = 'www-data' }
    default:  { fail("osfamily ${::osfamily} is unsupported by class puppetmaster.") }
  }
}
