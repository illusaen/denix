{ den, lib, ... }:
{
  den.aspects.chat = {
    includes = lib.attrValues den.aspects.chat._;

    _.vesktop.hm = {
      programs.vesktop = {
        enable = true;

        vencord.settings = {
          autoUpdate = false;
          autoUpdateNotification = false;
          notifyAboutUpdates = false;
          useQuickCss = true;
          transparent = true;

          plugins = {
            ClearURLs.enabled = true;
            FixYoutubeEmbeds.enabled = true;
            FakeNitro.enabled = true;
          };
        };
      };

      xdg.configFile."autostart/vesktop.desktop" = lib.mkDefault {
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
