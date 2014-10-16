class puppetmaster::firewall::puppetexplorer {
  firewall { '320 allow puppetexplorer access':
    port   => 443,
    proto  => tcp,
    action => accept,
  }
}
