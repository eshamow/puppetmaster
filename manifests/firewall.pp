class puppetmaster::firewall {
  firewall { '100 allow ssh access':
    port   => 22,
    proto  => tcp,
    action => accept,
  }
  firewall { '200 allow puppetdb access':
    port   => 8081,
    proto  => tcp,
    action => accept,
  }
  firewall { '250 allow puppet access':
    port   => 8140,
    proto  => tcp,
    action => accept,
  }
  firewall { '300 allow mco access':
    port   => 61613,
    proto  => tcp,
    action => accept,
  }
}
