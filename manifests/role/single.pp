# NOTE: Must call this with profile parameters passed via data bindings
class puppetmaster::role::single {
  class { 'puppetmaster::profile': }
  #  class { 'puppetmaster::profile::puppetboard': }
  #  class { 'puppetmaster::profile::puppetexplorer': }
}
