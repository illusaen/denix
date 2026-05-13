{
  helpers,
  ...
}:
{
  den.aspects.base.fonts = {
    os =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      let
        inherit (lib)
          mkOption
          types
          ;
        inherit (helpers) mapListToAttrsWith mkSubmoduleOption mkThemeType;
        fontOption = mkOption {
          type = mkThemeType { };
        };
        sizeOption = mkOption {
          type = types.int;
        };
      in
      {
        options.my.fonts = mkSubmoduleOption (
          mapListToAttrsWith [ "sans" "mono" "emoji" "icon" ] fontOption
          // {
            sizes = mkSubmoduleOption (mapListToAttrsWith [ "terminal" "applications" "desktop" ] sizeOption);
          }
        );

        config = {
          fonts.packages =
            (with pkgs; [
              font-awesome
              maple-mono.NF-CN-unhinted
            ])
            ++ (lib.pipe config.my.fonts [
              (lib.filterAttrs (_: v: builtins.isAttrs v && builtins.hasAttr "package" v))
              (lib.mapAttrsToList (_: value: value.package))
            ]);

          my.fonts = {
            sans = {
              name = "Inter";
              package = pkgs.inter;
            };
            mono = {
              name = "Monaspace Neon NF";
              package = pkgs.monaspace;
            };
            emoji = {
              name = "Noto Color Emoji";
              package = pkgs.noto-fonts-color-emoji;
            };
            icon = {
              name = "Material Symbols Outlined";
              package = pkgs.material-symbols;
            };
            sizes = {
              applications = 12;
              desktop = 12;
              terminal = 12;
            };
          };
        };
      };
    nixos =
      { config, ... }:
      {
        fonts.fontconfig.defaultFonts = rec {
          monospace = [ config.my.fonts.mono.name ];
          serif = sansSerif;
          sansSerif = [ config.my.fonts.sans.name ];
        };
      };
  };
}
