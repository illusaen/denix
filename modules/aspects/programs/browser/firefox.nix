{ lib, ... }:
{
  den.aspects.programs.browser.firefox = {
    darwin.homebrew.casks = [ "firefox" ];

    nixos =
      { pkgs, ... }:
      let
        firefoxTheme = "${pkgs.local.whitesur-gtk-theme}/share/firefox-theme";
        installFirefoxTheme = pkgs.writeShellApplication {
          name = "install-firefox-theme";
          runtimeInputs = with pkgs; [
            coreutils
            findutils
          ];
          text = ''
            firefox_dir="$HOME/.config/mozilla/firefox"
            [ -d "$firefox_dir" ] || exit 0

            find "$firefox_dir" -mindepth 2 -maxdepth 2 -name prefs.js -printf '%h\0' |
              while IFS= read -r -d "" profile; do
                ln -sfn ${lib.escapeShellArg firefoxTheme} "$profile/chrome"
              done
          '';
        };
      in
      {
        programs.firefox = {
          enable = true;
          languagePacks = [
            "en-US"
            "zh-CN"
          ];
          policies = {
            DisableTelemetry = true;
            DisplayMenuBar = "never";
            OfferToSaveLogins = false;
          };
          preferences = {
            "browser.startup.homepage" = "https://google.com";
            "browser.tabs.drawInTitlebar" = true;
            "browser.uidensity" = 0;
            "svg.context-properties.content.enabled" = true;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "widget.gtk.rounded-bottom-corners.enabled" = true;
          };
        };
        systemd.user.services.install-firefox-theme = {
          description = "Install WhiteSur Firefox theme";
          wantedBy = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = lib.getExe installFirefoxTheme;
          };
        };
        systemd.user.paths.install-firefox-theme = {
          wantedBy = [ "graphical-session.target" ];
          pathConfig.PathExistsGlob = "%h/.config/mozilla/firefox/*/prefs.js";
        };
      };
  };
}
