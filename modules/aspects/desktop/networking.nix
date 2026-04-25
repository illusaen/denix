{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.networking ];
  den.aspects.networking = den.lib.perHost {
    nixos =
      { lib, ... }:
      {
        networking.networkmanager.enable = true;
        networking.useDHCP = lib.mkDefault true;

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
  };
}
