################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class alcesservices::dns (
  $serviceip=$alcesservices::master_ip,
  $servicealias=$alcesservices::master_alias,

  $hostfiles=false,
  $named=true,
  $dnsnetworks=[],
  $forwarddns=[],
)
{

  $serviceentry="${serviceip}\t${servicealias}"

  if $hostfiles {
    file {'/etc/hosts':
      ensure=>present,
      mode=>0644,
      owner=>'root',
      group=>'root',
      content=>template("alcesservices/dns/hosts.el6.erb")
    }
  }
  if $named {
    if $alcesservices::role == 'master' {
      package {['bind','bind-utils','bind-chroot']:
        ensure=>installed,
      }
      service {'named':
        ensure=>running,
        enable=>true,
        require=>Package['bind'],
      }
      file {'/etc/named.conf':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        content=>template("alcesservices/dns/named.conf.erb"),
        notify=>Service['named']
      }
      alcesservices::dns_zone { $alcesnetwork::network::dnsnetworks:
        notify=>Service['named']
      }
      service {'dnsmasq':
         enable=>false,
         ensure=>stopped,
      }
    }
  }
  else {
    service {'dnsmasq':
      enable=>true,
      ensure=>running,
    }
  }
}
