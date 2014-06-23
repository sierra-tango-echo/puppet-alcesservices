################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class site_specific (
  $profile='generic'
){
  #Call you own puppet classes here, beware of conflicts with the alces_stack module

  #ROLE - (SLAVE OR MASTER)
  notify {$alces_role:}

  notify {$profile:}

  #MAChINE
  notify {$alces_machine:}

  file {'/tmp/testfile':
    ensure=>present,
    source=>"puppet:///modules/site_specific/test.file",
  }

    
}
