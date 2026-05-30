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
        inherit (lib) mkOption types;
        inherit (myLib) mapListToAttrsWith mkSubmoduleOption mkStrOption;
        sizeOption =
          default:
          mkOption {
            type = types.int;
            inherit default;
          };
      in
      {
        options.my.fonts = mkSubmoduleOption {
          sans = mkStrOption "Inter";
          mono = mkStrOption "Monaspace Neon NF";
          emoji = mkStrOption "Noto Color Emoji";
          icon = mkStrOption "Material Symbols Outlined";
          sizes = mkSubmoduleOption (
            mapListToAttrsWith [ "terminal" "applications" "desktop" ] (sizeOption 12)
          );
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
      monospace = [ self.my.fonts.mono ];
      serif = sansSerif;
      sansSerif = [ self.my.fonts.sans ];
    };
  };
}
