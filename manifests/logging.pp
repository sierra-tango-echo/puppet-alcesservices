################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class alcesservices::logging
{
  $service=$alcesservices::master_ip

  if $alcesservices::role == 'slave' {
    package {'rsyslog':
      ensure=>installed
    }
    package {'syslog-ng':
      ensure=>absent
    }
    service {'rsyslog':
      ensure=>running,
      enable=>true
    }
    file {'/etc/rsyslog.conf':
      ensure=>present,
      mode=>0644,
      owner=>'root',
      group=>'root',
      content=>template('alcesservices/logging/rsyslog.conf.el6.erb'),
      notify=>Service['rsyslog'],
      require=>Package['rsyslog']
    }
  }
  if $alcesservices::role == 'master' {
    package {'syslog-ng':
      ensure=>installed
    }
    package {'rsyslog':
      ensure=>absent
    } 
    service {'syslog-ng':
      ensure=>running,
      enable=>true
    }
    file {'/etc/syslog-ng/syslog-ng.conf':
      ensure=>present,
      mode=>0644,
      owner=>'root',
      group=>'root',
      content=>template('alcesservices/logging/syslog-ng.conf.erb'),
      notify=>Service['syslog-ng'],
      require=>Package['syslog-ng']
    }
    file {'/etc/logrotate.d/syslog-ng.alces':
      ensure=>present,
      mode=>0644,
      owner=>'root',
      group=>'root',
      content=>template('alcesservices/logging/logrotate-syslog-ng.erb'),
    }
  }
}
