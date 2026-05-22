{
  den,
  self,
  ...
}:
{
  den.aspects.base.includes = with den.aspects.base; [ fonts ];

  den.aspects.base.fonts = {
    flake-config =
      {
        myLib,
        lib,
        ...
      }:
      let
        inherit (lib)
          mkOption
          types
          ;
        inherit (myLib) mapListToAttrsWith mkSubmoduleOption;
        fontOption = mkOption {
          type = types.submodule {
            options = {
              name = mkOption { type = types.str; };
            };
          };
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

        config.my.fonts = {
          sans = {
            name = "Inter";
          };
          mono = {
            name = "Monaspace Neon NF";
          };
          emoji = {
            name = "Noto Color Emoji";
          };
          icon = {
            name = "Material Symbols Outlined";
          };
          sizes = {
            applications = 12;
            desktop = 12;
            terminal = 12;
          };
        };
      };

    os =
      { pkgs, ... }:
      {
        fonts.packages = with pkgs; [
          font-awesome
          maple-mono.NF-CN-unhinted
          inter
          monaspace
          noto-fonts-color-emoji
          material-symbols
        ];
      };
    nixos.fonts.fontconfig.defaultFonts = rec {
      monospace = [ self.my.fonts.mono.name ];
      serif = sansSerif;
      sansSerif = [ self.my.fonts.sans.name ];
    };
  };
}
