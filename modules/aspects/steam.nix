{ den, lib, ... }:
{
  den.aspects.steam = {
    includes = lib.attrValues den.aspects.steam._;

    _.enable = den.lib.perHost {
      persistUser.directories = [ ".local/share/Steam" ];

      darwin =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [ steam ];
        };

      nixos.programs.steam.enable = true;
    };

    _.autostart = den.lib.perUser {
      hjem.files = {
        ".config/autostart/steam.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Exec=steam -silent
          Hidden=false
          NoDisplay=false
          X-GNOME-Autostart-enabled=true
          Name=Steam
          Comment=Start Steam on login
        '';
      };
    };
  };
}
