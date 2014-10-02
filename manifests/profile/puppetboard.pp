class puppetmaster::profile::puppetboard (
  $master = puppetmaster::master
) inherits puppetmaster::profile {
  class { 'apache::mod::wsgi': }
  class { 'puppetboard': }
  class { 'puppetboard::apache::vhost':
    name => $master,
    port => 80,
  }
}
