{
  den.aspects.theming.gtk = {
    nixos = {
      pkgs,
      fleet,
      lib,
      host,
      ...
    }: let
      inherit
        (lib)
        generators
        isBool
        boolToString
        escape
        optionalAttrs
        ;

      toIni = generators.toINI {
        mkKeyValue = key: value: let
          value' =
            if isBool value
            then boolToString value
            else toString value;
        in "${escape ["="] key}=${value'}";
      };
      mkGtkSettings = {
        gtkVersion,
        font,
        theme ? null,
        iconTheme,
        cursorTheme,
        colorScheme,
      }:
        optionalAttrs (font != null) {
          gtk-font-name = let
            fontSize =
              if font.size != null
              then font.size
              else 11;
          in "${font.name} ${toString fontSize}";
        }
        // optionalAttrs (theme != null) {"gtk-theme-name" = theme.name;}
        // optionalAttrs (iconTheme != null) {"gtk-icon-theme-name" = iconTheme.name;}
        // optionalAttrs (cursorTheme != null) {"gtk-cursor-theme-name" = cursorTheme.name;}
        // optionalAttrs (cursorTheme != null && cursorTheme.size != null) {
          "gtk-cursor-theme-size" = cursorTheme.size;
        }
        // optionalAttrs (colorScheme == "dark") {"gtk-application-prefer-dark-theme" = true;}
        // optionalAttrs (gtkVersion == 4 && colorScheme == "dark") {"gtk-interface-color-scheme" = 2;}
        // optionalAttrs (gtkVersion == 4 && colorScheme == "light") {"gtk-interface-color-scheme" = 3;};

      inherit (fleet.my) theming fonts base16;

      commonSettings = gtkVersion: {
        font = {
          name = fonts.sans;
          size = fonts.sizes.applications;
        };
        theme = theming.gtkTheme;
        inherit (theming) iconTheme cursorTheme;
        inherit (base16) colorScheme;
        inherit gtkVersion;
      };

      gtkSettings = gtkVersion: {
        text = toIni {
          Settings = mkGtkSettings (commonSettings gtkVersion);
        };
      };
    in {
      environment.sessionVariables = {
        GTK_THEME = theming.gtkTheme.name;
        XDG_DATA_DIRS = lib.mkBefore ["/run/current-system/sw/share"];
      };
      environment.systemPackages = [
        pkgs.local.${theming.gtkTheme.packageName}
      ];
      environment.etc = {
        "xdg/gtk-3.0/settings.ini" = gtkSettings 3;
        "xdg/gtk-4.0/settings.ini" = gtkSettings 4;
        "xdg/gtk-3.0/bookmarks".text = lib.concatMapStrings (l: l + "\n") [
          "file:///home/${host.system-owner}/Projects"
          "file:///home/${host.system-owner}/Downloads"
        ];
      };
      programs.dconf = {
        enable = true;
        profiles.user.databases = [
          {
            settings."org/gnome/desktop/interface" = let
              settings = commonSettings 3;
            in
              lib.filterAttrs (_: v: v != null) {
                "font-name" = settings.font.name or null;
                "gtk-theme" = settings.theme.name or null;
                "icon-theme" = settings.iconTheme.name or null;
                "cursor-theme" = settings.cursorTheme.name or null;
                "cursor-size" = lib.gvariant.mkUint32 (settings.cursorTheme.size or null);
                "color-scheme" =
                  if settings ? colorScheme && settings.colorScheme != null
                  then "prefer-${settings.colorScheme}"
                  else null;
              };
          }
        ];
      };
    };
  };
}
