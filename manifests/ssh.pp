################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class alcesservices::ssh (
  $rsh=false,
  $rsa_key,
  $rsa_pubkey,
  $nogenerallogin=false,
  $hostbasedssh=false,
  $masterip=$alcesservices::master_ip,
  $masteralias=$alcesservices::master_alias,
  $root_rsa_key,
  $root_rsa_pubkey,
  $rootloginnopassword=true,
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

  #force host key if we have one
  if ($rsa_key != '') and ($rsa_pubkey != '') {
    file {'/etc/ssh/ssh_host_rsa_key':
      ensure=>present,
      mode=>0600,
      owner=>'root',
      group=>'root',
      content=>template('alcesservices/ssh/ssh_host_rsa_key.erb'),
    }
    file {'/etc/ssh/ssh_host_rsa_key.pub':
      ensure=>present,
      mode=>0644,
      owner=>'root',
      group=>'root',
      content=>template('alcesservices/ssh/ssh_host_rsa_key.pub.erb'),
    }
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

  if $hostbasedssh {
    file {'/etc/hosts.equiv':
      ensure=>present,
      mode=>0644,
      owner=>'root',
      group=>'root',
      content=>template('alcesservices/ssh/hosts.equiv.erb'),
    }

    if $alcesservices::role == 'slave' {
      file {'/root/.shosts':
        ensure=>present,
        mode=>0600,
        owner=>'root',
        group=>'root',
        content=>template('alcesservices/ssh/hosts.equiv.erb'),
      }
      file {'/root/.rhosts':
        ensure=>present,
        mode=>0600,
        owner=>'root',
        group=>'root',
        content=>template('alcesservices/ssh/hosts.equiv.erb'),
      }
    }

    file {'/etc/ssh/ssh_known_hosts':
      ensure=>present,
      mode=>0644,
      owner=>'root',
      group=>'root',
      content=>template('alcesservices/ssh/ssh_known_hosts.erb')
    }
  }
  else {
    file {'/root/.ssh':
      ensure=>directory,
      mode=>700,
      owner=>'root',
      group=>'root',
    }

    if $root_rsa_key and $root_rsa_pubkey {
      file {'/root/.ssh/id_alcescluster':
        ensure=>present,
        mode=>0600,
        owner=>'root',
        group=>'root',
        content=>template('alcesservices/ssh/ssh_root_rsa_key.erb'),
      }
      file {'/root/.ssh/id_alcescluster.pub':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        content=>template('alcesservices/ssh/ssh_root_rsa_key.pub.erb'),
      }
      if $rootloginnopassword {
        file_line {'root-authorized-keys':
          ensure=>present,
          path=>'/root/.ssh/authorized_keys',
          line=>$root_rsa_pubkey,
          require=>File['/root/.ssh/authorized_keys']
        }
        file {'/root/.ssh/authorized_keys':
          ensure=>present,
          mode=>0600,
          owner=>'root',
          group=>'root',
        }
      }
    }
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
