{ den, lib, ... }:
{
  den.aspects.vesktop = {
    includes = lib.attrValues den.aspects.vesktop._;

    _.enable = den.lib.perHost {
      os =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [ vesktop ];
        };
    };

    _.config = den.lib.perUser {
      hjem =
        {
          pkgs,
          osConfig,
          ...
        }:
        let
          configDir = if pkgs.stdenv.isDarwin then "Library/Application Support" else ".config";
        in
        {
          xdg.config.files."autostart/vesktop.desktop" = lib.mkIf pkgs.stdenv.isLinux {
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
          files = {
            "${configDir}/vesktop/settings.json".source = ./vesktop-settings.json;
            "${configDir}/vesktop/settings/settings.json".source = ./vencord-settings.json;
            "${configDir}/vesktop/themes/theme.css".source = ./theme.css;
            "${configDir}/vesktop/themes/colors.css".source = ./colors.css;
            "${configDir}/vesktop/themes/fonts.css".text = ''
              :root {
                --font-primary: ${osConfig.myLib.fonts.sans.name};
                --font-display: ${osConfig.myLib.fonts.sans.name};
                --font-code: ${osConfig.myLib.fonts.mono.name};
              }
            '';
          };
        };
    };
  };
}
