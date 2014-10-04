class puppetmaster::profile::puppetboard (
  $master = $puppetmaster::master
) inherits puppetmaster::params {
  class { 'apache::mod::wsgi': }
  class { 'python':
    virtualenv => true,
  } ->
  class { '::puppetboard':
    manage_virtualenv => false,
  }
  class { 'puppetboard::apache::vhost':
    vhost_name => $master,
    port => 80,
  }
}
