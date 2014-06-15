################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class alcesservices::time (
  $servicealias=$alcesservices::master_ip,
  $ntp=true,
  $ntpservers,
)
{
  if $ntp {
    package {'ntp':
      ensure=>installed,
    }
    service {'ntpd':
      ensure=>running,
      enable=>true,
    }
    if $alcesservices::role == 'slave' {
      file {'/etc/sysconfig/ntpd':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        source=>'puppet:///modules/alcesservices/time/slave/sysconfig-ntp.el6',
        notify=>Exec['syncclocks']
      }
      exec {'syncclocks':
        command=>'/sbin/service ntpd stop; /usr/sbin/ntpd -q -g -x; /sbin/hwclock --systohc --utc',
        refreshonly=>true,
        notify=>Service['ntpd']
      }
    }

    file {'/etc/ntp.conf':
      ensure=>present,
      mode=>0600,
      owner=>'root',
      group=>'root',
      content=>multitemplate(
            "alcesservices/dynamic/time/$alcesservices::machine/ntp.conf.erb",
            "alcesservices/dynamic/time/$alcesservices::profile/ntp.conf.erb",
            "alcesservices/dynamic/time/$alcesservices::role/ntp.conf.erb",
            "alcesservices/dynamic/time/generic/ntp.conf.erb"),
      require=>Package['ntp'],
      notify=>Service['ntpd']
    }
  }
  
}
