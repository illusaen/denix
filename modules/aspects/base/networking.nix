{
  den.aspects.base.networking = {
    nixos =
      { host, lib, ... }:
      {
        networking.networkmanager.enable = true;

        systemd.network = {
          enable = true;
          wait-online.enable = false;
          networks = {
            "10-lan" = {
              matchConfig.Name = "eno1";
              address = [ "${lib.head host.ipv4}/24" ];
              routes = [ { Gateway = "192.0.1.1"; } ];
              linkConfig.RequiredForOnline = "routable";
            };
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
