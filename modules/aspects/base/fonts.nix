{ den, lib, ... }:
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
  fontsOption = mkOption {
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
  fontsConfig = {
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
in
{
  options.fleet.my.fonts = fontsOption;

  config = {
    fleet.my.fonts = fontsConfig;

    den.aspects.base.includes = with den.aspects.base; [ fonts ];

    den.aspects.base.fonts = {
      fleet = {
        options.my.fonts = fontsOption;
        config.my.fonts = fontsConfig;
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
