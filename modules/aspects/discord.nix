{ den, lib, ... }:
{
  den.aspects.discord = {
    includes = lib.attrValues den.aspects.discord._;

    _.enable = den.lib.perHost {
      persistUser.directories = [
        ".config/discord"
      ];

      os =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [ (discord.override { withOpenASAR = true; }) ];
        };
    };

    _.configure = den.lib.perUser {
      hjem =
        {
          pkgs,
          ...
        }:
        {
          files.".config/autostart/vesktop.desktop" = lib.mkIf pkgs.stdenv.isLinux {
            text = ''
              [Desktop Entry]
              Type=Application
              Name=Vesktop
              Exec=${pkgs.vesktop}/bin/vesktop --start-minimized
              X-GNOME-Autostart-enabled=true
              NoDisplay=true
              NotShowIn=niri
            '';
          };
        };
    };
  };
}
