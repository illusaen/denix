{ den, lib, ... }:
{
  den.aspects.chat = {
    includes = lib.attrValues den.aspects.chat._;

    _.vesktop =
      { host, ... }:
      {
        os =
          { pkgs, ... }:
          {
            environment.systemPackages = with pkgs; [ vesktop ];
          };

        md =
          { pkgs, ... }:
          let
            jsonFormat = pkgs.formats.json { };
            configDir = if pkgs.stdenv.isDarwin then "Library/Application Support" else ".config";
            cfg = {
              settings = {
                checkUpdates = false;
                minimizeToTray = true;
                tray = true;
              };
              vencord.settings = {
                autoUpdate = false;
                autoUpdateNotification = false;
                notifyAboutUpdates = false;
                useQuickCss = true;
                transparent = true;
                enabledThemes = [ "theme.css" ];
                theme = ''
                  @import "colors.css";

                  :root {
                      --font-primary: ${host.fonts.sans.name};
                      --font-display: ${host.fonts.sans.name};
                      --font-code: ${host.fonts.mono.name};
                  }
                '';
                plugins = {
                  ClearURLs.enabled = true;
                  FixYoutubeEmbeds.enabled = true;
                  FakeNitro.enabled = true;
                };
              };
            };
          in
          {
            file.home."${configDir}/vesktop/settings.json".source =
              jsonFormat.generate "vesktop-settings" cfg.settings;
            file.home."${configDir}/vesktop/settings/settings.json".source =
              jsonFormat.generate "vencord-settings" cfg.vencord.settings;
            file.home."${configDir}/vesktop/themes/theme.css}".source =
              pkgs.writeText "vesktop-theme" cfg.vencord.settings.theme;
            file.home."${configDir}/vesktop/themes/colors.css}".source = ../../resources/themes/vesktop.css;

            file.xdg_config."autostart/vesktop.desktop".text = ''
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
      };

    _.element = den.lib.perHost {
      os =
        { pkgs, ... }:
        {
          nixpkgs.overlays = [
            (_: prev: {
              element-desktop = prev.element-desktop.overrideAttrs (old: {
                postFixup = (old.postFixup or "") + ''
                  sed -i 's|^Exec=\([^ ]*\) .*|Exec=\1 --password-store="gnome-libsecret"|' \
                    $out/share/applications/element-desktop.desktop
                '';
              });
            })
          ];
          environment.systemPackages = with pkgs; [ element-desktop ];
        };
    };
  };
}
