{
  den,
  lib,
  ...
}:
{
  den.aspects.desktop.includes = [ den.aspects.gtk ];
  den.aspects.gtk =
    let
      inherit (lib)
        generators
        isBool
        boolToString
        escape
        optionalAttrs
        isString
        ;

      toIni = generators.toINI {
        mkKeyValue =
          key: value:
          let
            value' = if isBool value then boolToString value else toString value;
          in
          "${escape [ "=" ] key}=${value'}";
      };

      formatGtk2Option =
        n: v:
        let
          v' =
            if isBool v then
              boolToString v
            else if isString v then
              ''"${v}"''
            else
              toString v;
        in
        "${escape [ "=" ] n} = ${v'}";

      mkGtkSettings =
        {
          gtkVersion,
          font,
          theme ? null,
          iconTheme,
          cursorTheme,
          colorScheme,
        }:
        optionalAttrs (font != null) {
          gtk-font-name =
            let
              fontSize = if font.size != null then font.size else 11;
            in
            "${font.name} ${toString fontSize}";
        }
        // optionalAttrs (theme != null) { "gtk-theme-name" = theme.name; }
        // optionalAttrs (iconTheme != null) { "gtk-icon-theme-name" = iconTheme.name; }
        // optionalAttrs (cursorTheme != null) { "gtk-cursor-theme-name" = cursorTheme.name; }
        // optionalAttrs (cursorTheme != null && cursorTheme.size != null) {
          "gtk-cursor-theme-size" = cursorTheme.size;
        }
        // optionalAttrs (colorScheme == "dark") { "gtk-application-prefer-dark-theme" = true; }
        // optionalAttrs (gtkVersion == 4 && colorScheme == "dark") { "gtk-interface-color-scheme" = 2; }
        // optionalAttrs (gtkVersion == 4 && colorScheme == "light") { "gtk-interface-color-scheme" = 3; };

      _gtk = pkgs: {
        theme = {
          package = pkgs.adw-gtk3;
          name = "adw-gtk3";
        };
      };

      _commonSettings = fonts: theming: {
        font = fonts.sans // {
          size = fonts.sizes.applications;
        };
        inherit (theming) iconTheme;
        inherit (theming) cursorTheme;
        inherit (theming) colorScheme;
      };
    in
    {
      includes = lib.attrValues den.aspects.gtk._;

      _.enable = den.lib.perHost {
        nixos =
          { pkgs, config, ... }:
          let
            inherit (config.myLib) fonts theming;

            gtk = _gtk pkgs;
            commonSettings = _commonSettings fonts theming;
          in
          {
            programs.dconf = {
              enable = true;
              profiles.user.databases = [
                {
                  settings."org/gnome/desktop/interface" =
                    let
                      settings = {
                        gtkVersion = 3;
                        inherit (gtk) theme;
                      }
                      // commonSettings;
                      settingsGtk = mkGtkSettings settings;
                    in
                    lib.filterAttrs (_: v: v != null) {
                      "font-name" = settingsGtk."gtk-font-name" or null;
                      "gtk-theme" = settingsGtk."gtk-theme-name" or null;
                      "icon-theme" = settingsGtk."gtk-icon-theme-name" or null;
                      "cursor-theme" = settingsGtk."gtk-cursor-theme-name" or null;
                      "cursor-size" = lib.gvariant.mkUint32 (settingsGtk."gtk-cursor-theme-size" or null);
                      "color-scheme" =
                        if settings ? colorScheme && settings.colorScheme != null then
                          "prefer-${settings.colorScheme}"
                        else
                          null;
                    };
                }
              ];
            };
          };
      };

      _.configure = den.lib.perUser (
        { user, ... }:
        {
          hjem =
            {
              pkgs,
              lib,
              osConfig,
              ...
            }:
            let
              inherit (lib) mkMerge flatten;
              inherit (osConfig.myLib) fonts theming;

              gtkExtraCss = ''
                @import url("dank-colors.css");
              '';
              gtkFinalCss = pkgs.runCommandLocal "gtk.css" { } ''
                cat ${
                  theming.colors {
                    template = ./_templates/gtk.css.mustache;
                    extension = ".css";
                  }
                } >>$out
                echo ${lib.escapeShellArg gtkExtraCss} >>$out
              '';
              gtkCssFile = version: { "gtk-${version}/gtk.css".source = gtkFinalCss; };

              gtk = _gtk pkgs;

              commonSettings = _commonSettings fonts theming;

              bookmarks = [
                "file:///home/${user.name}/Projects"
                "file:///home/${user.name}/Downloads"
              ];
            in
            {
              xdg.config.files = mkMerge (flatten [
                (map gtkCssFile [
                  "3.0"
                  "4.0"
                ])
                {
                  "gtk-2.0/gtkrc".text =
                    let
                      settings = mkGtkSettings (
                        commonSettings
                        // {
                          gtkVersion = 2;
                          inherit (gtk) theme;
                          colorScheme = null;
                        }
                      );
                    in
                    lib.concatMapStrings (n: "${formatGtk2Option n settings.${n}}\n") (lib.attrNames settings);
                }
                {
                  "gtk-3.0/settings.ini".text = toIni {
                    Settings = mkGtkSettings (
                      {
                        gtkVersion = 3;
                        inherit (gtk) theme;
                      }
                      // commonSettings
                    );
                  };
                }
                {
                  "gtk-3.0/bookmarks".text = lib.concatMapStrings (l: l + "\n") bookmarks;
                }
                {
                  "gtk-4.0/settings.ini".text = toIni {
                    Settings = mkGtkSettings (
                      {
                        gtkVersion = 4;
                      }
                      // commonSettings
                    );
                  };
                }
              ]);

              xdg.data.files."flatpak/overrides/global".text = ''
                [Context]
                filesystems=${osConfig.users.users.${user.name}.home}/.themes/${gtk.theme.name}:ro

                [Environment]
                GTK_THEME=${gtk.theme.name}
              '';

              files.".themes/${gtk.theme.name}".source = pkgs.stdenvNoCC.mkDerivation {
                name = "flattenedGtkTheme";
                src = "${gtk.theme.package}/share/themes/${gtk.theme.name}";

                installPhase = ''
                  cp --recursive . $out
                  cat ${gtkFinalCss} | tee --append $out/gtk-{3,4}.0/gtk.css
                '';
              };
            };
        }
      );
    };
}
