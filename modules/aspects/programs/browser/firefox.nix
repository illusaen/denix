{ inputs, ... }:
{
  flake-file.inputs.firefox-addons = {
    url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.programs.browser.firefox = {
    darwin.homebrew.casks = [ "firefox" ];

    nixos =
      {
        pkgs,
        config,
        fleet,
        lib,
        ...
      }:
      {
        options.programs.firefox.globalExtensions = lib.mkOption {
          type = lib.types.listOf (
            lib.types.oneOf [
              lib.types.package
              (lib.types.submodule {
                options = {
                  package = lib.mkOption {
                    type = lib.types.package;
                  };
                  settings = lib.mkOption {
                    type = lib.types.attrsOf (pkgs.formats.json { }).type;
                    default = { };
                    description = "Json formatted options for this extension.";
                  };
                };
              })
            ]
          );
          default = [ ];
        };

        config.nixpkgs.overlays = [ inputs.firefox-addons.overlays.default ];

        config.xdg.mime.defaultApplications =
          let
            application = "firefox.desktop";
            mimeTypes = [
              "text/html"
              "x-scheme-handler/http"
              "x-scheme-handler/https"
              "x-scheme-handler/about"
            ];
          in
          lib.genAttrs mimeTypes (_: application);

        config.programs.firefox = {
          enable = true;
          languagePacks = [
            "en-US"
            "zh-CN"
          ];
          globalExtensions = with pkgs.firefox-addons; [
            ublock-origin
            sponsorblock
            darkreader
            onepassword-password-manager
          ];
          autoConfig =
            let
              convertFontSize = size: toString (builtins.floor ((size * 4.0 / 3.0) + 0.5));
              inherit (fleet.my.fonts.sizes) terminal applications;
            in
            builtins.readFile ./betterfox.js
            + ''
              pref("font.size.monospace.x-western", ${convertFontSize terminal});
              pref("font.size.variable.x-western", ${convertFontSize applications});
              pref("browser.display.use_document_fonts", 0);
            '';
          policies = {
            DisableTelemetry = true;
            DisplayMenuBar = "never";
            OfferToSaveLogins = false;
            Homepage = {
              URL = "http://google.com/";
              StartPage = "previous-session";
            };
            SearchEngines.Add = [
              {
                Name = "NixOS Packages";
                URLTemplate = "https://search.nixos.org/packages?type=packages&channel=unstable&query={searchTerms}";
                Method = "GET";
                IconURL = "https://wiki.nixos.org/nixos.png";
                Alias = "@np";
                Description = "NixOS packages";
              }
              {
                Name = "NixOS Options";
                URLTemplate = "https://search.nixos.org/options?type=options&channel=unstable&query={searchTerms}";
                Method = "GET";
                IconURL = "https://wiki.nixos.org/nixos.png";
                Alias = "@no";
                Description = "NixOS options";
              }
              {
                Name = "NixOS Wiki";
                URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
                Method = "GET";
                IconURL = "https://wiki.nixos.org/nixos.png";
                Alias = "@nw";
                Description = "Official NixOS wiki";
              }
            ];
            ExtensionSettings = lib.pipe config.programs.firefox.globalExtensions [
              (builtins.filter (elem: (elem.package or elem) ? addonId))
              (map (
                elem:
                let
                  package = elem.package or elem;
                in
                lib.nameValuePair package.addonId (
                  {
                    installation_mode = "force_installed";
                    install_url = "file://${package.outPath}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${package.addonId}.xpi";
                  }
                  // (elem.settings or { })
                )
              ))
              lib.listToAttrs
            ];
          };
          preferences = {
            "browser.ctrlTab.sortByRecentlyUsed" = false;
            "devtools.chrome.enabled" = true;

            "gfx.webrender.all" = true;
            "widget.dmabuf.force-enabled" = true;
            "media.av1.enabled" = true;
            "media.ffmpeg.vaapi.enabled" = true;
            "media.rdd-ffmpeg.enabled" = true;
            "media.rdd-vpx.enabled" = true;
            "media.rdd-process.enabled" = true;

            "browser.tabs.drawInTitlebar" = true;
            "browser.uidensity" = 0;
            "svg.context-properties.content.enabled" = true;
            "widget.gtk.rounded-bottom-corners.enabled" = true;

            # Privacy
            "privacy.userContext.enabled" = true;
            "extensions.webcompat-reporter.enabled" = false;
            "browser.ping-centre.telemetry" = false;
            "browser.urlbar.eventTelemetry.enabled" = false;

            "extensions.pocket.enabled" = false;
            "extensions.abuseReport.enabled" = false;
            "extensions.formautofill.creditCards.enabled" = false;
            "identity.fxaccounts.toolbar.enabled" = false;
            "browser.contentblocking.report.lockwise.enabled" = false;

            # Disable annoying web features
            "dom.push.enabled" = false;
            "dom.push.connection.enabled" = false;
            "dom.battery.enabled" = false;
            "dom.private-attribution.submission.enabled" = false;
          };
        };
        config.systemd.user.services.install-firefox-theme =
          let
            installFirefoxTheme = pkgs.writeShellApplication {
              name = "install-firefox-theme";
              runtimeInputs = with pkgs; [
                coreutils
                findutils
              ];
              text = ''
                firefox_dir="$HOME/.config/mozilla/firefox"
                [ -d "$firefox_dir" ] || mkdir -p "$firefox_dir"

                find "$firefox_dir" -mindepth 2 -maxdepth 2 -name prefs.js -printf '%h\0' |
                  while IFS= read -r -d "" profile; do
                    ln -sfn ${lib.escapeShellArg "${pkgs.local.whitesur-gtk-theme}/share/firefox-theme"} "$profile/chrome"
                  done
              '';
            };
          in
          {
            description = "Install WhiteSur Firefox theme";
            wantedBy = [ "graphical-session.target" ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = lib.getExe installFirefoxTheme;
            };
          };
        config.systemd.user.paths.install-firefox-theme = {
          wantedBy = [ "graphical-session.target" ];
          pathConfig.PathExistsGlob = "%h/.config/mozilla/firefox/*/prefs.js";
        };
      };
  };
}
