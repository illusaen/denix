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
          nixpkgs.overlays = [
            (_: prev: {
              discord = prev.discord.override { withOpenASAR = true; };
            })
          ];
          environment.systemPackages = with pkgs; [ discord ];
        };
    };

    _.configure = den.lib.perUser {
      hjem =
        {
          pkgs,
          ...
        }:
        {
          xdg.config.files."autostart/discord.desktop" = lib.mkIf pkgs.stdenv.isLinux {
            text = ''
              [Desktop Entry]
              Type=Application
              Name=Discord
              Exec=${pkgs.discord}/bin/discord --start-minimized
              X-GNOME-Autostart-enabled=true
              NoDisplay=true
              NotShowIn=niri
            '';
          };
        };
    };
  };
}
