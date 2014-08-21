################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class alcesservices::httpd (
  $apache=true,
)
{
  if $alcesservices::role == 'master' {
    package {'httpd':
      ensure=>installed
    }
    service {'httpd':
      enable=>'true',
      ensure=>'running',
      require=>Package['httpd']
    }
    file {'/var/lib/alces/docs':
      ensure=>directory,
      owner=>'root',
      group=>'root',
      mode=>'0755',
    }
    file {'/etc/httpd/conf.d/alces-docs.conf':
       ensure=>present,
       mode=>0644,
       owner=>'apache',
       group=>'apache',
       content=>template("alcesservices/alces-docs.conf.erb"),
       require=>Package['httpd'],
       notify=>Service['httpd']
    }
  }
}
