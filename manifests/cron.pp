################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
###############################################################################
class alcesservices::cron
{

  package {'vixie-cron':
    ensure=>installed,
  }

  #Disable cron called updatedb on slave nodes
  if $alcesservices::role=='slave' {
    file {'/etc/cron.daily/mlocate.cron':
          ensure=>absent
    }
  }
  file {'/etc/cron.hourly/scratchdirs.cron':
       ensure=>present,
       mode=>0755,
       group=>'root',
       owner=>'root',
       source=>'puppet:///modules/alcesservices/cron/scratchdirs'
  }
  #dont delete scratchdirs
  file {'/etc/cron.daily/tmpwatch':
       ensure=>present,
       mode=>0755,
       group=>'root',
       owner=>'root',
       source=>'puppet:///modules/alcesservices/cron/tmpwatch'
  }
}
