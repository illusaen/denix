{ den, ... }:
{
  den.aspects.nvidia = den.lib.perHost {
    nixos =
      { config, ... }:
      {
        services.xserver.videoDrivers = [ "nvidia" ];

        hardware.nvidia = {
          modesetting.enable = true;
          open = false;
          nvidiaSettings = false;
          package = config.boot.kernelPackages.nvidiaPackages.latest;
          powerManagement.enable = true;
        };

        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };
      };
  };
}
