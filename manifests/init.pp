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
  $master_ip = hiera('alcesbase::masterip'),
  #Master Alias (network master dns alias)
  $master_alias = hiera('alcesbase::masteralias'),
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

  #Configure NFS
  class { 'alcesservices::nfs':
    fsexports=>hiera('alcesservices::nfsexports',undef),
    fsimports=>hiera('alcesservices::nfsimports',undef),
  }

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

  #Configure DNS
  class { 'alcesservices::dns':
    dnsnetworks=>$alcesnetwork::network::dnsnetworks,
    forwarddns=>$alcesnetwork::network::forwarddns,
  }

  #Configure SSH
  class { 'alcesservices::ssh':
    rsa_key=>hiera('alcesservices::rsa_key',''),
    rsa_pubkey=>hiera('alcesservices::rsa_pubkey',''),
    nogenerallogin=>hiera('alcesservices::nogenerallogin',false),
    root_rsa_key=>hiera('alcesservices::root_rsa_key'),
    root_rsa_pubkey=>hiera('alcesservices::root_rsa_pubkey'),
    rootloginnopassword=>hiera('alcesservices::rootloginnopassword',true),
  }
 
  #Configure Deployment
  class { 'alcesservices::deployment':
    root_passwd_md5=>hiera('alcesservices::root_passwd_md5','$1$2iZFK1$0AKQwQPb8rb.3V8J/hyMw1'),
  }

  #Configure config management
  class { 'alcesservices::configmgt':
  }

  #Cofigure VPN
  class { 'alcesservices::vpn':
  }
}
