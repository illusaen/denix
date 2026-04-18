{ den, ... }:
{
  den.aspects.desktop.includes = [ den.aspects.gdm ];
  den.aspects.gdm = den.lib.perHost {
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
