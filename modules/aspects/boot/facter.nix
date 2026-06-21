{
  den.aspects.boot.facter = {
    nixos = {host, ...}: {
      hardware.facter = {
        reportPath = host.facts or null;
        detected.dhcp.enable = false;
      };
    };
  };
}
