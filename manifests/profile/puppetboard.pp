class puppetmaster::profile::puppetboard {
  class { 'apache::mod::wsgi': }
  class { 'puppetboard': }
  class { 'puppetboard::apache::vhost':
    port => 80,
  }
}
