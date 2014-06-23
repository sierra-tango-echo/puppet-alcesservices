################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class alcesservices::vpn (
  $openvpn=true,
  $masterip=$alcesservices::master_ip,
  $masteralias=$alcesservices::master_alias,
  $externaldnsname=$alcesnetwork::network::externaldnsname,
)
{
  if $openvpn {
    package {'openvpn':
      ensure=>installed,
    }
    service {'openvpn':
      ensure=>running,
      enable=>true,
      require=>Package['openvpn'],
    }
    if $alcesservices::role == 'master' {
      package {'easy-rsa':
        ensure=>installed,
      }
      file {'/etc/openvpn/secure.conf':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        content=>template("alcesservices/vpn/secure.conf.erb"),
        require=>[Package['openvpn'],File['/etc/openvpn/ccd']],
        notify=>Service['openvpn'],
      }
      file {'/etc/openvpn/externalvpn.conf':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        content=>template("alcesservices/vpn/externalvpn.conf.erb"),
        require=>[Package['openvpn']],
        notify=>Service['openvpn'],
      }
      file {'/etc/openvpn/ccd':
        ensure=>directory,
        mode=>0744,
        owner=>'root',
        group=>'root',
        require=>Package['openvpn'],
      }
      file {'/opt/alces/docs/vpn':
        ensure=>directory,
        mode=>0755,
        owner=>'root',
        group=>'root',
        require=>File['/opt/alces/docs'],
      }
      file {'/etc/openvpn/secureclient.example':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        content=>template("alcesservices/vpn/secure.example.erb"),
        require=>[Package['openvpn']]
      }
      file {'/opt/alces/docs/vpn/client.example':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        content=>template("alcesservices/vpn/client.example.erb"),
        require=>[Package['openvpn'],File['/opt/alces/docs/vpn']]
      }
      file {'/var/lib/alces/bin/setup-openvpn-certs.sh':
        ensure=>present,
        mode=>700,
        owner=>'root',
        group=>'root',
        content=>template("alcesservices/vpn/setup-openvpn-certs.sh.template"),
        require=>File['/var/lib/alces/bin/'],
        notify=>Service['openvpn'],
      }
      exec {'setup-openvpn-certs':
        command=>inline_template("/var/lib/alces/bin/setup-openvpn-certs.sh <%=@masteralias%>.<%=scope.lookupvar('alcesnetwork::network::primary_domain')%>"),
        creates=>'/etc/openvpn/easy-rsa',
        require=>[File['/var/lib/alces/bin/setup-openvpn-certs.sh'],File['/opt/alces/docs/vpn']]
      }
    }
    if $alcesservices::role == 'slave' {
      #Alces init does most of this setup
        
    }
  }
}
