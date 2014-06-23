################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
define alcesservices::nfs::fsexport (
  $path=$title,
  $nfsexportoptions="ro,no_root_squash,no_subtree_check,async",
  $parents=undef,
)
{
  if $parents != undef {
    file {$parents:
      ensure=>directory,
      mode=>0755,
      owner=>'root',
      group=>'root'
    }
  }
  file {"dir-${path}":
    name=>$path,
    ensure=>directory,
    mode=>0755,
    owner=>'root',
    group=>'root',
  }
  file_line {"export-${path}":
    path=>'/etc/exports',
    ensure=>present,
    line=>inline_template("<%=@path%> <%=scope.lookupvar('alcesnetwork::network::primary_network')%>/<%=scope.lookupvar('alcesnetwork::network::primary_netmask')%>(<%=@nfsexportoptions%>) <%=scope.lookupvar('alcesnetwork::network::secure_network')%>/<%=scope.lookupvar('alcesnetwork::network::secure_netmask')%>(<%=@nfsexportoptions%>)"),
    require=>File['/etc/exports'],
    notify=>Service['nfs']
  } 
}
