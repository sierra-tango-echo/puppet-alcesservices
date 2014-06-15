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

  #Cofigure Time
  class { 'alcesservices::time':
    ntpservers=>hiera('alcesservices::time::ntpservers',[]),
  } 

  #Configure user authentication
  class { 'alcesservices::userauth':
    enablenis=>hiera('alcesservices::userauth::nis',false),
    enableldap=>hiera('alcesservices::userauth::ldap',false),
    enablekrb=>hiera('alcesservices::userauth::kerberos',false),
    nisdomain=>$alcesservices::clustername,
    ldapbase=>hiera('alcesservices::userauth::ldapbase','ldap://10.10.0.1/'),
    ldapuri=>hiera('alcesservices::userauth::ldapuri',"dc=prv,dc=${alcesservices::clustername},dc=cluster"),
    addomain=>hiera('alcesservices::userauth::addomain','ad.site.com'),
    adserver=>hiera('alcesservices::userauth::adserver','127.0.0.1'),
  }
  
  #Configure Backup
  class { 'alcesservices::backup':
  }

  #Configure Cron
  class { 'alcesservices::cron':
  }

  #Configure Logging
  class { 'alcesservices::logging':
  }
  
  #Configure Mail
  class { 'alcesservices::mail':
    maildomain=>$alcesnetwork::network::primary_domain,
    relayhost=>hiera('alcesservices::mail::relayhost',$master_ip),
  }
}
