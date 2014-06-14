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
  #Cluster name:
  $clustername = hiera('alcesbase::clustername','alcescluster'),
  #Master IP (network master IP addr)
  $master_ip = hiera('alcesbase::masterip')
)
{
  #Configure apache
  class { 'alcesservices::httpd':
  }

}
