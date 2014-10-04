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
  }
  class { 'puppetboard::apache::conf': }
}
