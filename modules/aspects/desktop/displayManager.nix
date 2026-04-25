{ den, ... }:
{
  den.aspects.desktop._.gdm = den.lib.perHost {
    nixos = {
      services.displayManager = {
        enable = true;
        gdm = {
          enable = true;
          wayland = true;
        };
      };
    };

    persist.directories = [ "/var/lib/gdm" ];
  };
}
