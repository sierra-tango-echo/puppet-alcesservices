################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class alcesservices::mail (
  $postfix=true,
  $relayhost=$alcesservices::master_ip,
  $maildomain=$alcesnetwork::network::primary_domain,
)
{

  if $postfix {
    package {'postfix':
      ensure=>installed
    }
    package {'sendmail':
      ensure=>absent
    }

    file {'/etc/postfix/main.cf':
          ensure=>present,
          mode=>0644,
          owner=>'root',
          group=>'root',
          content=>multitemplate(
            "alcesservices/dynamic/mail/$alcesservices::machine/main.cf.el6.erb",
            "alcesservices/dynamic/mail/$alcesservices::profile/main.cf.el6.erb",
            "alcesservices/dynamic/mail/$alcesservices::role/main.cf.el6.erb",
            "alcesservices/dynamic/mail/generic/main.cf.el6.erb"),
          require=>Package['postfix'],
          notify=>Service['postfix']
    }
  
    service {'postfix':
             enable=>true,
             ensure=>'running',
             require=>Package['postfix']
    }

    file {'/etc/postfix/master-rewrite-sender':
         ensure=>present,
         mode=>0644,
         owner=>'root',
         group=>'root',
         content=>template('alcesservices/mail/master-rewrite-sender.erb'),
         require=>Package['postfix'],
     }
     file {'/etc/postfix/master-rewrite-domain':
         ensure=>present,
         mode=>0644,
         owner=>'root',
         group=>'root',
         content=>template('alcesservices/mail/master-rewrite-domain.erb'),
         require=>Package['postfix'],
     }

       
  } else {
    service {'postfix':
             enable=>'false',
             ensure=>'stopped'
    }
  }


  
}
