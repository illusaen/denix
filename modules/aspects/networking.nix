{ den, ... }:
{
  den.schema.host.includes = [ den.aspects.networking ];
  den.aspects.networking = {
    nixos =
      { host, ... }:
      {
        networking.networkmanager.enable = true;

        systemd.network = {
          enable = true;
          networks."10-lan" = {
            matchConfig = {
              Name = "eno1";
            };
            networkConfig.DHCP = "ipv4";
            address = [ "${host.ip}/24" ];
            routes = [ { Gateway = "192.0.1.1"; } ];
            linkConfig.RequiredForOnline = "routable";
          };
        };

        hardware.bluetooth = {
          enable = true;
          powerOnBoot = true;
          settings = {
            General = {
              Experimental = true;
            };
          };
        };

        services.blueman.enable = true;
      };

    darwin =
      { config, ... }:
      {
        networking.computerName = config.networking.hostName;
      };

    persist.directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
    ];
  };
}
