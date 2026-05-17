{
  den,
  inputs,
  self,
  ...
}:
{
  den.aspects.base.includes = with den.aspects.base; [ fonts ];

  den.aspects.base.fonts = {
    flake-config =
      {
        myLib,
        system,
        lib,
        ...
      }:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        inherit (lib)
          mkOption
          types
          ;
        inherit (myLib) mapListToAttrsWith mkSubmoduleOption mkThemeType;
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

        config.my.fonts = {
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

    os =
      { pkgs, lib, ... }:
      {
        fonts.packages =
          (with pkgs; [
            font-awesome
            maple-mono.NF-CN-unhinted
          ])
          ++ (lib.pipe self.my.fonts [
            (lib.filterAttrs (_: v: builtins.isAttrs v && builtins.hasAttr "package" v))
            (lib.mapAttrsToList (_: value: value.package))
          ]);
      };
    nixos = _: {
      fonts.fontconfig.defaultFonts = rec {
        monospace = [ self.my.fonts.mono.name ];
        serif = sansSerif;
        sansSerif = [ self.my.fonts.sans.name ];
      };
    };
  };
}
