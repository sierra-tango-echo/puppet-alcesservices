################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class alcesservices::backup (
  $dirvish=true
)
{
  if $dirvish {
    if $alcesservices::role == 'master' {
      package {'dirvish':
        ensure=>installed,
      }
      file {'/etc/dirvish/dirvish-cronjob':
        ensure=>present,
        mode=>0700,
        owner=>'root',
        group=>'root',
        content=>template('alcesservices/backup/dirvish-cronjob.erb'),
        require=>[Package['dirvish'],Class['alcesservices::cron']]
      }
      file {'/etc/dirvish/master.conf':
        ensure=>present,
        mode=>0600,
        owner=>'root',
        group=>'root',
        content=>template('alcesservices/backup/master.conf.erb'),
        require=>Package['dirvish'],
      }
      file {'/etc/cron.d/dirvish':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        content=>template('alcesservices/backup/dirvish.cron.erb'),
        require=>Package['dirvish'],
      }
      file {'/home/backup':
        ensure=>directory, 
        mode=>600,
        owner=>'root',
        group=>'root',
        require=>Package['dirvish'],
      }
    }
  }
}
