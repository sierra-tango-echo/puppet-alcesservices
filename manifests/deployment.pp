################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class alcesservices::deployment (
  $cobbler=true,
  $masterip=$alcesservices::master_ip,
  $root_passwd_md5,
  $replacecobblerdb=false, 
)
{
  if $cobbler {
    if $alcesservices::role == 'master' {
      package {'cobbler':
                ensure=>installed
              }
      package {'cobbler-web':
                ensure=>installed
              }
      package {'dhcp':
                ensure=>installed
              }
      package {'tftp':
                ensure=>installed
              }
      service {'cobblerd':
               enable=>'true',
               ensure=>'running',
               require=>Package['cobbler'],
               notify=>Exec['cobblersync']
              }
      service {'dhcpd':
               enable=>'true',
              }
      file {'/etc/cobbler/settings':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            content=>template("alcesservices/cobbler/settings.erb"),
            require=>Package['cobbler'],
            notify=>Service['cobblerd']
       }
       file {'/etc/cobbler/modules.conf':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            content=>template("alcesservices/cobbler/modules.conf.erb"),
            require=>Package['cobbler'],
            notify=>Service['cobblerd']
       }
       file {'/etc/cobbler/dhcp.template':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            content=>template("alcesservices/cobbler/dhcp.template.erb"),
            require=>Package['cobbler'],
            notify=>Service['cobblerd']
       }
       file {'/etc/cobbler/default.erb':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            content=>template("alcesservices/cobbler/default.ks.erb"),
            require=>Package['cobbler'],
            notify=>Service['cobblerd']
       }
       file {'/etc/httpd/conf.d/alces-depot.conf':
             ensure=>present,
             mode=>0644,
             owner=>'apache',
             group=>'apache',
             content=>template("alcesservices/cobbler/alces-depot.conf.erb"),
             require=>Package['httpd'],
             notify=>Service['httpd']
       }
       file {'/etc/httpd/conf.d/alces-profiles.conf':
             ensure=>present,
             mode=>0644,
             owner=>'apache',
             group=>'apache',
             content=>template("alcesservices/cobbler/alces-profiles.conf.erb"),
             require=>Package['httpd'],
             notify=>Service['httpd']
       }
       file {'/etc/httpd/conf.d/alces-personality.conf':
             ensure=>present,
             mode=>0644,
             owner=>'apache',
             group=>'apache',
             content=>template("alcesservices/cobbler/alces-personality.conf.erb"),
             require=>Package['httpd'],
             notify=>Service['httpd']
       }
       file {'/etc/httpd/conf.d/passenger.conf':
            mode=>0644,
            owner=>'apache',
            group=>'apache',
            content=>template("alcesservices/cobbler/passenger.conf.erb"),
            require=>Package['httpd'],
            notify=>Service['httpd']
       }
       file {'/etc/httpd/conf.d/alces-puppet.conf':
            mode=>0644,
            owner=>'apache',
            group=>'apache',
            content=>template("alcesservices/cobbler/alces-puppet.conf.erb"),
            require=>Package['httpd'],
            notify=>Service['httpd']
       }

       #Profile builder
       file {'/var/lib/alces/clusterware/etc/profiles/':
            ensure=>directory,
            mode=>0755,
            owner=>'root',
            group=>'root',
       }
       file {'/var/lib/alces/clusterware/etc/profiles/slave':
             ensure=>directory,
             mode=>0755,
             owner=>'root',
             group=>'root'
       }
       file {'/var/lib/alces/clusterware/etc/profiles/slave/localization.part':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            content=>template("alcesservices/cobbler/slave/localization.part.erb"),
       }
       file {'/var/lib/alces/clusterware/etc/profiles/slave/security.part':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            content=>template("alcesservices/cobbler/slave/security.part.erb"),
       }
       file {'/var/lib/alces/clusterware/etc/profiles/slave/disk.part':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            content=>template("alcesservices/cobbler/slave/disk.part.erb"),
       }
       file {'/var/lib/alces/clusterware/etc/profiles/slave/disk-headnode.part':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            content=>template("alcesservices/cobbler/slave/disk-headnode.part.erb"),
       }
       file {'/var/lib/alces/clusterware/etc/profiles/slave/disk-storage.part':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            content=>template("alcesservices/cobbler/slave/disk-storage.part.erb"),
       }
       file {'/var/lib/alces/clusterware/etc/profiles/slave/disk-login.part':
	    ensure=>present,
	    mode=>0644,
            owner=>'root',
	    group=>'root',
	    content=>template("alcesservices/cobbler/slave/disk-login.part.erb"),
	}
       file {'/var/lib/alces/clusterware/etc/profiles/slave/disk-compute.part':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            content=>template("alcesservices/cobbler/slave/disk-compute.part.erb"),
       }
       file {'/var/lib/alces/clusterware/etc/profiles/slave/disk-vcompute.part':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            content=>template("alcesservices/cobbler/slave/disk-vcompute.part.erb"),
       }
       file {'/var/lib/alces/clusterware/etc/profiles/slave/packages.part':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            content=>template("alcesservices/cobbler/slave/packages.part.erb"),
       }
       file {'/var/lib/alces/clusterware/etc/profiles/slave/postscript.part':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            content=>template("alcesservices/cobbler/slave/postscript.part.erb"),
       }
       file {'/var/lib/alces/clusterware/etc/profiles/slave/prescript.part':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            content=>template("alcesservices/cobbler/slave/prescript.part.erb"),
       }
       file {'/var/lib/alces/clusterware/etc/profiles/slave/kickstart.cfg':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            content=>template("alcesservices/cobbler/slave/kickstart.cfg.erb"),
       }
       
       #Cobbler internal config files
       file {'/var/lib/cobbler/config/distros.d/base_os.json':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            require=>Package['cobbler'],
            notify=>Service['cobblerd'],
            content=>template("alcesservices/cobbler/config/base_os.json.erb"),
            replace=>$replacecobblerdb,
       }
       file {'/var/lib/cobbler/config/profiles.d/BASE.json':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            require=>Package['cobbler'],
            notify=>Service['cobblerd'],
            content=>template("alcesservices/cobbler/config/base.json.erb"),
            replace=>$replacecobblerdb,
       } 
       file {'/var/lib/cobbler/config/profiles.d/SLAVE.json':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            require=>Package['cobbler'],
            notify=>Service['cobblerd'],
            content=>template("alcesservices/cobbler/config/slave.json.erb"),
            replace=>$replacecobblerdb,
       } 
       file {'/var/lib/cobbler/config/profiles.d/SLAVE_SERIAL.json':
            ensure=>present,
            mode=>0644,
            owner=>'root',
            group=>'root',
            require=>Package['cobbler'],
            notify=>Service['cobblerd'],
            content=>template("alcesservices/cobbler/config/slave_serial.json.erb"),
            replace=>$replacecobblerdb,
       }
       package {'tftp-server':
            ensure=>installed
       }
       file {'/etc/xinetd.d/tftp':
            ensure=>present,
            mode=>644,
            owner=>'root',
            group=>'root',
            require=>Package['tftp-server'],
            notify=>Service['xinetd'],
            content=>template("alcesservices/cobbler/tftp.erb"),
       }
       exec {'cobblersync':
        command=>'/usr/bin/cobbler sync',
        require=>[Package['cobbler'],Service['cobblerd']],
        refreshonly=>true,
      }
    }
  }
    


  
}
