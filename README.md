# puppet-piwik

Puppet manifest to install and configure Piwik

[![Build Status](https://secure.travis-ci.org/icalvete/puppet-piwik.png)](http://travis-ci.org/icalvete/puppet-piwik)

See [Piwik site](https://piwik.org/)

## Requires:

* Only works on Ubuntu
* [hiera](http://docs.puppetlabs.com/hiera/1/index.html)
* https://github.com/icalvete/apache2:
* MySQL client (mysql-client package)

## usage

```puppet
  package {'mysql-client':
    ensure => present
  }

  $apache26_dists = hiera('apache26_dists')
  $apache26       = member($apache26_dists, $lsbdistcodename)

  class {'roles::apache2_server':
    php               => 7,
    wsgi              => true
  }

  class {'roles::syslog_sender_server':
    syslog_remote_server => '192.168.33.5'
  }

  class {'piwik':
    admin            => 'admin',
    admin_password   => 'admin111',
    admin_email      => 'icalvete@gmail.com',
    admin_token_auth => '3474851a3410906697ec77337df7bbe4',
    db_host          => '192.168.33.15',
    db_user          => 'piwik',
    db_pass          => 'piwik',
    db_name          => 'piwik'
  }
  
  piwik::user {'isra':
    password => 'isra111',
    email    => 'icalvete@gmail.com',
    alias    => 'other admin',
    admin    => true,
  }

  piwik::site {'my_site':
    url => 'http://my_site.org',
  }
```

## Authors:

Israel Calvete Talavera <icalvete@gmail.com>
