{ den, ... }:
{
  den.aspects.desktop.includes = [ den.aspects.gui ];

  den.aspects.gui = den.lib.perHost {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          qalculate-gtk
          inkscape
        ];

        services.flatpak.enable = true;
      };

    persist.directories = [
      "/var/lib/flatpak"
    ];

    persistUser.directories = [
      ".local/share/flatpak"
    ];
  };
}
