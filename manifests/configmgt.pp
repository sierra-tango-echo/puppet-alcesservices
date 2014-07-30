################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class alcesservices::configmgt (
  $puppet=true,
  $masterip=$alcesservices::master_ip,
  $masteralias=$alcesservices::master_alias,
)
{
  if $puppet {
    if $alcesservices::role == 'master' {
      package {'puppet-server':
        ensure=>installed,
      }
      package {'hiera':
        ensure=>installed,
      }
      file {'/etc/puppet/manifests/site.pp':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        content=>template("alcesservices/configmgt/site.pp.erb"),
        require=>Package['puppet-server'],
      }
      service {'puppetmaster':
        ensure=>running,
        enable=>true,
        require=>Package['puppet-server'],
      }
    }
    package {'puppet':
      ensure=>installed,
    }
    service {'puppet':
      ensure=>running,
      enable=>true
    }
    file {'/etc/puppet/puppet.conf':
      ensure=>present,
      mode=>0644,
      owner=>'root',
      group=>'root',
      content=>template("alcesservices/configmgt/puppet.conf.$alcesservices::role.erb"),
      require=>Package['puppet'],
    }

    file {'/etc/puppet/modules/site_specific':
      ensure=>present,
      recurse=>true,
      source=>'puppet:///modules/alcesservices/configmgt/site_specific'
    }
    
  }
}
