################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class alcesservices::ssh (
  $rsh=false,
)
{

  package {'openssh-clients':
    ensure=>installed,
  }

  service {'sshd':
    ensure=>running,
    enable=>true
  }

  package {'openssh-server':
    ensure=>installed,
  }
 
  file {'/etc/ssh/ssh_config':
    ensure=>present,
    mode=>644,
    owner=>'root',
    group=>'root',
    source=>'puppet:///modules/alcesservices/ssh/sshconfig.el6', 
    require=>Package['openssh-clients']
  }
  file {'/etc/ssh/sshd_config':
    ensure=>present,
    mode=>644,
    owner=>'root',
    group=>'root',
    content=>template('alcesservices/ssh/sshdconfig.el6.erb'),
    require=>Package['openssh-server'],
    notify=>Service['sshd']
  } 
  if $rsh {
    package{'rsh-server':
      ensure=>installed
    }
    file_line {'securetty-rsh1':
      path=>'/etc/securetty',
      line=>'rsh',
    }
    file_line {'securetty-rsh2':
      path=>'/etc/securetty',
      line=>'rexec',
    }
    file_line {'secretty-rsh3':
      path=>'/etc/securetty',
      line=>'rlogin',
    }
  }
  file {'/etc/xinetd.d/rsh':
    ensure=>present,
    mode=>644,
    owner=>'root',
    group=>'root',
    content=>template('alcesservices/ssh/xinetd_rsh.el6.erb'),
    notify=>Service['xinetd']
  }
  file {'/etc/xinetd.d/rexec':
    ensure=>present,
    mode=>644,
    owner=>'root',
    group=>'root',
    content=>template('alcesservices/ssh/xinetd_rexec.el6.erb'),
    notify=>Service['xinetd']
  }
  file {'/etc/xinetd.d/rlogin':
    ensure=>present,
    mode=>644,
    owner=>'root',
    group=>'root',
    content=>template('alcesservices/ssh/xinetd_rlogin.el6.erb'),
    notify=>Service['xinetd']
  }
}
