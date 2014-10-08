class puppetmaster::firewall::puppetboard {
  firewall { '310 allow puppetboard access':
    port   => 80,
    proto  => tcp,
    action => accept,
  }
}
