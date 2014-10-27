################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class alcesservices (
  #Generic Alces variables
  #Supported profiles:
  # - generic
  $profile = hiera('alcesbase::profile','generic'),
  #Supported roles:
  # - slave
  # - master
  $role = hiera('alcesbase::role','slave'),
  #Supported machines
  # - generic
  $machine = hiera('alcesbase::machine','generic'),
  #Cluster name:
  $clustername = hiera('alcesbase::clustername','alcescluster'),
  #HA (ha enabled?)
  $ha = $alcesbase::ha,
  #Keep os jitter minimal
  $jitter=$alcesbase::jitter
)
{

  service {'xinetd':
    ensure=>running,
    enable=>true
  }
  package {'xinetd':
    ensure=>'installed'
  }

  #Configure NFS
  class { 'alcesservices::nfs':
    fsexports=>hiera('alcesservices::nfsexports',undef),
    fsimports=>hiera('alcesservices::nfsimports',undef),
  }

  #Configure Cron
  class { 'alcesservices::cron':
  }

  #Configure SSH
  class { 'alcesservices::ssh':
  }
 
}
