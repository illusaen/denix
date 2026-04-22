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

    _.config = den.lib.perUser (
      { host, ... }:
      {
        hjem =
          {
            pkgs,
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
                  --font-primary: ${host.fonts.sans.name};
                  --font-display: ${host.fonts.sans.name};
                  --font-code: ${host.fonts.mono.name};
                }
              '';
            };
          };
      }
    );
  };
}
