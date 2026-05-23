{ den, self, ... }:
{
  den.aspects.theming.includes = with den.aspects.theming; [ qt ];

  den.aspects.theming.qt = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          kdePackages.qt6ct
          kdePackages.qtstyleplugin-kvantum
          libsForQt5.qt5ct
          libsForQt5.qtstyleplugin-kvantum
        ];

        qt = {
          enable = true;
          style = "kvantum";
          platformTheme = "qt5ct";
        };
      };

    provides.to-users.hjem =
      {
        pkgs,
        lib,
        osConfig,
        ...
      }:
      let
        inherit (self.my) fonts;

        qtSettingsFile = qtct: {
          "${qtct}/${qtct}.conf".source =
            (pkgs.formats.ini {
              listToValue = values: lib.concatStringsSep ", " values;
            }).generate
              "${qtct}-conf"
              {
                Appearance = {
                  custom_palette = true;
                  standard_dialogs = "xdgdesktopportal";
                  inherit (osConfig.qt) style;
                  icon_theme = self.my.theming.iconTheme.name;
                };

                Fonts = {
                  fixed = ''"${fonts.mono},${toString fonts.sizes.applications}"'';
                  general = ''"${fonts.sans},${toString fonts.sizes.applications}"'';
                };
              };
        };

        kvantumPackage =
          let
            kvconfig = self.my.scheme {
              template = ./kvconfig.mustache;
              extension = ".kvconfig";
            };
            svg = self.my.scheme {
              template = ./kvantum.svg.mustache;
              extension = ".svg";
            };
          in
          pkgs.runCommandLocal "base16-kvantum" { } ''
            directory="$out/share/Kvantum/Base16Kvantum"
            mkdir --parents "$directory"
            cp ${kvconfig} "$directory/Base16Kvantum.kvconfig"
            cp ${svg} "$directory/Base16Kvantum.svg"
          '';
      in
      {
        xdg.config.files = lib.mkMerge (
          lib.flatten [
            (map qtSettingsFile [
              "qt5ct"
              "qt6ct"
            ])
            (lib.mkIf (osConfig.qt.style == "kvantum") {
              "Kvantum/kvantum.kvconfig" = {
                generator = lib.generators.toINI { };
                value = {
                  General.theme = "Base16Kvantum";
                };
              };
              "Kvantum/Base16Kvantum".source = "${kvantumPackage}/share/Kvantum/Base16Kvantum";
            })
          ]
        );
      };
  };
}
