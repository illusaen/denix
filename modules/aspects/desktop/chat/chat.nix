{
  den,
  self,
  inputs,
  ...
}:
{
  den.aspects.desktop.includes = with den.aspects.desktop; [ chat ];

  den.aspects.desktop.chat = {
    provides.to-users.persistUser.directories = [
      ".config/Element"
    ];

    os =
      { pkgs, ... }:
      let
        vesktop-wrapped = inputs.wrappers.lib.wrapPackage (
          { config, lib, ... }:
          let
            builder = ''
              mkdir -p "$(dirname "$2")"
              cp "$1" "$2"
            '';
          in
          {
            inherit pkgs; # you can only grab the final package if you supply pkgs!
            package = pkgs.vesktop;
            flags."--user-data-dir" = "${placeholder config.outputName}";
            constructFiles.generatedTheme = {
              content = builtins.readFile ./vesktop.css;
              relPath = "themes/cosmic.css";
              inherit builder;
            };
            constructFiles.generatedVencordSettings = {
              content = lib.generators.toJSON { } {
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
              relPath = "settings/settings.json";
              inherit builder;
            };
            constructFiles.generatedQuickCss =
              let
                inherit (self.my) fonts;
                colors = self.my.scheme.withHashtag;
              in
              {
                content = ''
                  :root {
                    --font: "${fonts.sans}"; --font-code: "${fonts.mono}";

                    --base00: ${colors.base00}; --base01: ${colors.base01}; --base02: ${colors.base02};
                    --base03: ${colors.base03}; --base04: ${colors.base04}; --base05: ${colors.base05};
                    --base06: ${colors.base06}; --base07: ${colors.base07}; --base08: ${colors.base08};
                    --base09: ${colors.base09}; --base0A: ${colors.base0A}; --base0B: ${colors.base0B};
                    --base0C: ${colors.base0C}; --base0D: ${colors.base0D}; --base0E: ${colors.base0E};
                    --base0F: ${colors.base0F};
                  }
                '';
                relPath = "settings/quickCss.css";
              };
          }
        );
      in
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
        environment.systemPackages = with pkgs; [
          element-desktop
          vesktop-wrapped
        ];
      };

    nixos =
      { pkgs, ... }:
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
            ExecStart = "vesktop";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
      };
  };
}
