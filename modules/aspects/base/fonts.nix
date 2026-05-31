{ lib, ... }:
let
  inherit (lib)
    mkOption
    types
    pipe
    nameValuePair
    ;
  sizeOption =
    default:
    mkOption {
      type = types.int;
      inherit default;
    };
  mapListToAttrsWith =
    attrs: value:
    pipe attrs [
      (map (v: nameValuePair v value))
      builtins.listToAttrs
    ];
  mkStrOption =
    default:
    mkOption {
      type = types.str;
      inherit default;
    };
in
{
  options.fleet.my.fonts = mkOption {
    type = types.submodule {
      options = {
        sans = mkStrOption "Inter";
        mono = mkStrOption "Monaspace Neon NF";
        emoji = mkStrOption "Noto Color Emoji";
        icon = mkStrOption "Material Symbols Outlined";
        sizes = mkOption {
          type = types.submodule {
            options = mapListToAttrsWith [ "terminal" "applications" "desktop" ] (sizeOption 12);
          };
        };
      };
    };
  };

  config = {
    fleet.my.fonts = {
      sans = "Inter";
      mono = "Monaspace Neon NF";
      emoji = "Noto Color Emoji";
      icon = "Material Symbols Outlined";
      sizes = {
        terminal = 12;
        applications = 12;
        desktop = 12;
      };
    };

    den.aspects.base.fonts = {
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
      nixos =
        { fleet, ... }:
        {
          fonts.fontconfig.defaultFonts = rec {
            monospace = [ fleet.my.fonts.mono ];
            serif = sansSerif;
            sansSerif = [ fleet.my.fonts.sans ];
          };
        };
    };
  };
}
