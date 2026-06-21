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
        ;

      toIni = generators.toINI {
        mkKeyValue = key: value: let
          value' =
            if isBool value
            then boolToString value
            else toString value;
        in "${escape ["="] key}=${value'}";
      };

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
          Settings = let
            settings = commonSettings gtkVersion;
          in
            lib.filterAttrs (_: v: v != null) {
              gtk-font-name =
                if settings ? font && settings.font.name != null && settings.font.size != null
                then "${settings.font.name} ${toString settings.font.size}"
                else null;
              gtk-theme-name = settings.theme.name or null;
              gtk-icon-theme-name = settings.iconTheme.name or null;
              gtk-cursor-theme-name = settings.cursorTheme.name or null;
              gtk-cursor-theme-size = settings.cursorTheme.size or null;
              gtk-application-prefer-dark-theme =
                if settings ? colorScheme && settings.colorScheme != null
                then true
                else null;
            };
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
            settings."org/gnome/desktop/wm/preferences" = {"button-layout" = "close:";};
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
      system.userActivationScripts.installLibadwaitaTheme = ''
        echo "Installing whitesur theme to gtk-4.0"
        libadwaita_dir="$HOME/.config/gtk-4.0"
        [ -d "$libadwaita_dir" ] && rm -r "$libadwaita_dir"
        ln -sfn ${lib.escapeShellArg "${pkgs.local.${theming.gtkTheme.packageName}}/share/libadwaita-themes"} "$libadwaita_dir"
      '';
    };
  };
}
