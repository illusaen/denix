{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.networking ];
  den.aspects.networking = den.lib.perHost (
    { host }:
    {
      nixos = _: {
        # networking = {
        #   networkmanager.enable = true;
        #   useDHCP = lib.mkDefault true;
        #   interfaces.eno1 = {
        #     ipv4.addresses = [
        #       {
        #         address = host.ip;
        #         prefixLength = 24;
        #       }
        #     ];
        #   };
        #   defaultGateway = {
        #     address = "192.0.1.1";
        #     interface = "eno1";
        #   };
        # };
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

      persist.directories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/bluetooth"
      ];
    }
  );
}
