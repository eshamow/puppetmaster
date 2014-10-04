class puppetmaster::profile::puppetboard (
  $master = puppetmaster::master
) inherits puppetmaster::params {
  class { 'apache::mod::wsgi': }
  class { '::puppetboard': }
  class { 'puppetboard::apache::vhost':
    vhost_name => $master,
    port => 80,
  }
}
