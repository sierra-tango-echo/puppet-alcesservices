################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
define alcesservices::dns_zone (
  $zone=$title,
  $zonefilename_header="/var/named/",
  $replacedns=true,
)
{
  $zone_domain=inline_template("<%=scope.lookupvar(\"alcesnetwork::network::#{@zone}_domain\")%>")
  file {"zonefile-${title}":
        name=>"/var/named/${zone_domain}.zone",
        ensure=> present,
        mode=>0644,
        content=>template('alcesservices/dns/zone_template.erb'),
        require=>Package['bind'],
        replace=>$replacedns,
  }
  file {"zonefile-rr-${title}":
        name=>"/var/named/${zone_domain}.rr.zone",
        ensure=> present,
        mode=>0644,
        content=>template('alcesservices/dns/zone_rr_template.erb'),
        require=>Package['bind'],
        replace=>$replacedns,
  }
}
