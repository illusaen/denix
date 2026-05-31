{
  den.aspects.desktop.vesktop = {
    provides.to-users.persistUser.directories = [
      ".config/vesktop"
    ];

    os =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ vesktop ];
      };

    nixos =
      { pkgs, lib, ... }:
      {
        systemd.user.services.vesktop-start = {
          description = "Start vesktop on login";
          after = [
            "graphical-session.target"
            "graphical-session-pre.target"
          ];
          wantedBy = [ "graphical-session.target" ];
          serviceConfig = {
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
            ExecStart = "${lib.getExe pkgs.vesktop}";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
      };

    provides.to-users.hjem =
      {
        lib,
        pkgs,
        fleet,
        ...
      }:
      let
        inherit (fleet.my) fonts scheme;
        settings = {
          vesktop = { };
          vencord = {
            autoUpdate = false;
            autoUpdateNotification = false;
            useQuickCss = true;
            transparent = true;
            plugins = {
              ClearURLs.enabled = true;
              FixYoutubeEmbeds.enabled = true;
              FakeNitro.enabled = true;
            };
            enabledThemes = [ "cosmic.css" ];
          };
          themes.cosmic = ./vesktop.css;
          extraQuickCss =
            let
              colors = scheme.withHashtag;
            in
            ''
              :root {
                  --font: "${fonts.sans}";
                  --font-code: "${fonts.mono}";

                  --base00: ${colors.base00};
                  --base01: ${colors.base01};
                  --base02: ${colors.base02};
                  --base03: ${colors.base03};
                  --base04: ${colors.base04};
                  --base05: ${colors.base05};
                  --base06: ${colors.base06};
                  --base07: ${colors.base07};
                  --base08: ${colors.base08};
                  --base09: ${colors.base09};
                  --base0A: ${colors.base0A};
                  --base0B: ${colors.base0B};
                  --base0C: ${colors.base0C};
                  --base0D: ${colors.base0D};
                  --base0E: ${colors.base0E};
                  --base0F: ${colors.base0F};
              }
            '';
        };

        configDir = if pkgs.stdenv.hostPlatform.isDarwin then "Library/Application Support" else ".config";
      in
      {
        files = lib.mkMerge (
          lib.flatten [
            (lib.mkIf (settings.vesktop != { }) {
              "${configDir}/vesktop/settings.json" = {
                generator = lib.generators.toJSON { };
                value = settings.vesktop;
              };
            })
            (lib.mkIf (settings.vencord != { }) {
              "${configDir}/vesktop/settings/settings.json" = {
                generator = lib.generators.toJSON { };
                value = settings.vencord;
              };
            })
            (lib.mkIf (settings.extraQuickCss != "") {
              "${configDir}/vesktop/settings/quickCss.css".text = settings.extraQuickCss;
            })
            (lib.mapAttrs' (
              name: value:
              lib.nameValuePair "${configDir}/vesktop/themes/${name}.css" {
                source =
                  if builtins.isPath value || lib.isStorePath value then
                    value
                  else
                    pkgs.writeText "vesktop-themes-${name}" value;
              }
            ) settings.themes)
          ]
        );
      };
  };
}
