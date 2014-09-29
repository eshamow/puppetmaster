# NOTE: Must call this with profile parameters passed via data bindings
class puppetmaster::role::single {
  class { 'puppetmaster::profile': }
}
