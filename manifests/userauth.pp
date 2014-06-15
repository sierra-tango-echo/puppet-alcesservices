################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class alcesservices::userauth (
  $enablenis=false,
  $enableldap=false,
  $enablekrb=false,
  $nisdomain=$alcesservices::clustername,
  $ldapbase='ldap://10.10.0.1/',
  $ldapuri="dc=prv,dc=${alcesservices::clustername},dc=cluster",
  $addomain='ad.site.com',
  $adserver='127.0.0.1',
)
{
  if $alcesservices::role == 'master' {
    file {'/etc/default/useradd':
      ensure=>present,
      mode=>600,
      owner=>'root',
      group=>'root',
      content=>template('alcesservices/userauth/el6/useradd.erb')
    }
  }
  file {'/etc/nsswitch.conf':
          ensure=>present,
          mode=>0644,
          owner=>'root',
          group=>'root',
          content=>template('alcesservices/userauth/el6/nsswitch.erb')
  }
  file {'/etc/pam.d/password-auth-ac':
    ensure=>present,
    mode=>0644,
    owner=>'root',
    group=>'root',
    content=>template('alcesservices/userauth/el6/password-auth-ac'),
  }
  file {'/etc/pam.d/system-auth-ac':
    ensure=>present,
    mode=>0644,
    owner=>'root',
    group=>'root',
    content=>template('alcesservices/userauth/el6/system-auth-ac'),
  }

  package {'nscd':
    ensure=>installed,
  }

  service {'nscd': 
    ensure=>running,
    enable=>true,
    require=>Package['nscd']
  }

  if $enablekrb {
    package {'pam_krb5':
      ensure=>installed,
    }
    file {'/etc/krb5.conf':
      ensure=>present,
      mode=>0644,
      owner=>'root',
      group=>'root',
      content=>template('alcesservices/userauth/el6/krb5.conf.erb'),
    }

  }
  if $enableldap {
    package {'openldap-clients':
      ensure=>installed,
    }
    package {'pam_ldap':
      ensure=>installed,
    }
    package {'nss-pam-ldapd':
      ensure=>installed,
    }
    file {'/etc/pam_ldap.conf':
      ensure=>present,
      mode=>0644,
      owner=>'root',
      group=>'root',
      content=>template('alcesservices/userauth/el6/pam_ldap.conf.erb'),
      require=>Package['pam_ldap'],
    }
    file {'/etc/nslcd.conf':
      ensure=>present,
      mode=>0644,
      owner=>'root',
      group=>'root',
      content=>template('alcesservices/userauth/el6/nslcd.conf.erb'),
      require=>Package['nss-pam-ldapd'],
      notify=>Service['nslcd'],
    }
    service {'nslcd':
      ensure=>running,
      enable=>true,
      require=>Package['nss-pam-ldapd']
    }
    if $alcesservices::role == 'master' {
      package {'openldap-servers':
        ensure=>installed,
      }
      service {'slapd':
        ensure=>running,
        enable=>true,
        require=>Package['openldap-servers']
      }
      file {'/etc/sysconfig/ldap':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        content=>template('alcesservices/userauth/el6/sysconfig-ldap.erb'),
        require=>Package['openldap-servers'],
        notify=>Service['slapd']
      }
      file {'/etc/openldap/ldap.conf':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        content=>template('alcesservices/userauth/el6/ldap.conf.erb'),
        require=>Package['openldap-servers']
      }
      file {'/etc/openldap/slapd.conf':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        content=>template('alcesservices/userauth/el6/slapd.conf.erb'),
        require=>Package['openldap-servers']
      }
      file {'/etc/openldap/groups.ldiff':
        ensure=>present,
        mode=>0600,
        owner=>'root',
        group=>'root',
        content=>template('alcesservices/userauth/el6/groups.ldiff.erb'),
        require=>Package['openldap-servers']
      }
      file {'/etc/openldap/base.ldiff':
        ensure=>present,
        mode=>0600,
        owner=>'root',
        group=>'root',
        content=>template('alcesservices/userauth/el6/base.ldiff.erb'),
        require=>Package['openldap-servers']
      }
      file {'/var/lib/ldap/DB_CONFIG':
        ensure=>present,
        mode=>0640,
        owner=>'ldap',
        group=>'ldap',
        content=>template('alcesservices/userauth/el6/DB_CONFIG.erb'),
        require=>Package['openldap-servers']
      }
      file {'/var/lib/alces/bin/initldap.sh':
        ensure=>present,
        mode=>700,
        owner=>'root',
        group=>'root',
        content=>template('alcesservices/userauth/el6/initldap.sh.erb'),
        require=>File['/var/lib/alces/bin']
      }
      exec {'initldap':
        command=>'sh /var/lib/alces/bin/initldap.sh',
        unless=>'test -f /var/lib/ldap/__db.001',
        require=>[Package['openldap-servers'],File['/var/lib/alces/bin/initldap.sh']],
        notify=>Service['slapd']
      }
    }
  }

  if $enablenis {
    file {'/etc/yp.conf':
      ensure=>present,
      mode=>0644,
      owner=>'root',
      group=>'root',
      content=>multitemplate(
            "alcesservices/dynamic/userauth/$alcesservices::machine/yp.conf.erb",
            "alcesservices/dynamic/userauth/$alcesservices::profile/yp.conf.erb",
            "alcesservices/dynamic/userauth/$alcesservices::role/yp.conf.erb",
            "alcesservices/dynamic/userauth/generic/yp.conf.erb"),
      require=>Package['ypbind'],
      notify=>[Service['ypbind'],Exec['nisdomain']]
    }
    package { 'ypbind':
      ensure=>installed
    }
    exec {'nisdomain':
      command=>"/bin/nisdomainname ${nisdomain}",
      require=>Package['ypbind'],
      refreshonly=>true
    }

    if $alcesservices::role=='slave' {
      service { 'ypbind':
        ensure=>'running',
        enable=>true,
        require=>Package['ypbind'],
        subscribe=>Exec['nisdomain'],
      }
    } else {
      service {'ypbind':
        ensure=>'stopped',
        enable=>false,
      }
    }
    if $alcesservices::role=='master' {
      package { 'ypserv':
        ensure=>installed  
      }
      service { 'ypserv':
        ensure=>'running',
        enable=>true,
        require=>Package['ypserv']
      }
      service { 'yppasswdd':
        ensure=>'running',
        enable=>true,
        require=>Package['ypserv']
      }
      file {'/var/yp/securenets':
        ensure=>present,
        mode=>644,
        owner=>'root',
        group=>'root',
        content=>template("alcesservices/userauth/el6/securenets.erb"),
        require=>Package['ypserv'],
        notify=>Service['ypserv']
      }
      file {'/var/yp/Makefile':
        ensure=>present,
        mode=>644,
        owner=>'root',
        group=>'root',
        content=>template("alcesservices/userauth/el6/Makefile.erb"),
        require=>Package['ypserv'],
        notify=>Service['ypserv']
      }
      file {'/var/yp/nicknames':
        ensure=>present,
        mode=>644,
        owner=>'root',
        group=>'root',
        content=>template("alcesservices/userauth/el6/nicknames.erb"),
        require=>Package['ypserv'],
        notify=>Service['ypserv']
      }
    }
  } else {
    service { 'ypbind':
      ensure=>'stopped'
    }
  }
}
