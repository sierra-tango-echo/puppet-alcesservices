################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class alcesservices::nfs (
  $fsimports,
  $fsexports,
  $clustername=$alcesservices::clustername,
  $ha=$alcesservices::ha,
)
{ 

  package { 'nfs-utils':
    ensure=>'installed'
  }

  if ($fsexports != undef) {
     if ! $ha {
       service {'nfs':
             enable=>'true',
             ensure=>'running',
             require=>Package['nfs-utils']
       }
       service {"nfslock":
             enable=>'true',
             ensure=>'running',
             require=>Package['nfs-utils']
       }
       file {'/etc/exports':
          ensure=>present,
          mode=>0644,
          owner=>'root',
          group=>'root',
          replace=>'false',
          content=>template('alcesservices/nfs/exports.erb'),
          require=>Package['nfs-utils'],
          notify=>Service['nfs']
       }
       service {'smb':
             enable=>'true',
             ensure=>'running',
             require=>Package['samba']
       }
       create_resources( alcesservices::nfs::fsexport, $fsexports )
     }
     file {'/etc/sysconfig/nfs':
          ensure=>present,
          mode=>0644,
          owner=>'root',
          group=>'root',
          content=>template('alcesservices/nfs/sysconfig-nfs.erb'),
          require=>Package['nfs-utils'],
          notify=>Service['nfs']
     }
     package {'samba':
         ensure=>installed
     }
     file {'/etc/samba/smb.conf':
          ensure=>present,
          mode=>0644,
          owner=>'root',
          group=>'root',
          content=>template('alcesservices/nfs/samba.conf.erb'),
          require=>Package['samba'],
          notify=>Service['smb']
      }  
  }

  if $fsimports != undef {
     create_resources( alcesservices::nfs::fsimport, $fsimports )
  }
}
