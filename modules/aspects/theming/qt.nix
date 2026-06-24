{
  den.aspects.theming.qt = {
    nixos = {
      pkgs,
      host,
      config,
      lib,
      ...
    }: {
      qt = {
        enable = true;
        style = "kvantum";
        platformTheme = "qt5ct";
      };

      environment.sessionVariables = {
        QT_QPA_PLATFORM = "wayland";
      };

      system.userActivationScripts.installKvantumThemes = let
        themePackage = pkgs.local.${host.settings.theming.qtTheme.packageName};
      in ''
        kvantum_dir="$HOME/.config/Kvantum"
        mkdir -p "$kvantum_dir"

        for theme_src in ${lib.escapeShellArg "${themePackage}/share/Kvantum"}/*; do
          [ -d "$theme_src" ] || continue
          theme_name="$(basename "$theme_src")"
          theme_dest="$kvantum_dir/$theme_name"

          if [ -e "$theme_dest" ] && [ ! -L "$theme_dest" ]; then
            echo "Skipping existing Kvantum theme $theme_dest"
            continue
          fi

          ln -sfnT "$theme_src" "$theme_dest"
        done
      '';

      environment.etc = let
        fonts = host.settings.base.fonts;
        theming = host.settings.theming;
        qtSettingsFile = qtct: {
          "xdg/${qtct}/${qtct}.conf".source =
            (pkgs.formats.ini {
              listToValue = values: lib.concatStringsSep ", " values;
            }).generate
            "${qtct}-conf"
            {
              Appearance = {
                custom_palette = true;
                standard_dialogs = "xdgdesktopportal";
                inherit (config.qt) style;
                icon_theme = theming.iconTheme.name;
              };

              Fonts = {
                fixed = ''"${fonts.mono},${toString fonts.sizes.applications}"'';
                general = ''"${fonts.sans},${toString fonts.sizes.applications}"'';
              };
            };
        };
      in
        lib.mkMerge (lib.flatten [
          (map qtSettingsFile [
            "qt5ct"
            "qt6ct"
          ])
          (lib.mkIf (config.qt.style == "kvantum") {
            "xdg/Kvantum/kvantum.kvconfig" = {
              text = lib.generators.toINI {} {
                General.theme = theming.qtTheme.name;
              };
            };
          })
        ]);
    };
  };
}
