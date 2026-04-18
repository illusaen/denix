{ den, lib, ... }:
{
  den.aspects.vesktop = {
    includes = lib.attrValues den.aspects.vesktop._;

    _.enable = den.lib.perHost {
      persistUser.directories = [
        ".config/vesktop"
      ];

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
            lib,
            ...
          }:
          let
            configDir = if pkgs.stdenv.isDarwin then "Library/Application Support" else ".config";
          in
          {
            files = {
              ".config/autostart/vesktop.desktop" = lib.mkIf (!pkgs.stdenv.isDarwin) {
                text = ''
                  [Desktop Entry]
                  NotShowIn=niri
                  Categories=Network;InstantMessaging;Chat
                  Exec=vesktop --start-minimized
                  GenericName=Internet Messenger
                  Icon=vesktop
                  Keywords=discord;vencord;electron;chat
                  Name=Vesktop
                  StartupWMClass=Vesktop
                  Type=Application
                  Version=1.5
                '';
              };

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
