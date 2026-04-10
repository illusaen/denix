{ den, ... }:
{
  den.aspects.desktop.includes = [ den.aspects.gui ];

  den.aspects.gui = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          qalculate-gtk
          inkscape
        ];

        services.flatpak.enable = true;
      };
  };
}
