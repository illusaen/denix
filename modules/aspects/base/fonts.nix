{lib, ...}: let
  inherit
    (lib)
    mkOption
    types
    pipe
    nameValuePair
    ;
  sizeOption = default:
    mkOption {
      type = types.int;
      inherit default;
    };
  mapListToAttrsWith = attrs: value:
    pipe attrs [
      (map (v: nameValuePair v value))
      builtins.listToAttrs
    ];
  mkStrOption = default:
    mkOption {
      type = types.str;
      inherit default;
    };
in {
  config = {
    den.aspects.base.fonts = {
      settings = {
        sans = mkStrOption "Inter";
        mono = mkStrOption "Monaspace Neon NF";
        emoji = mkStrOption "Noto Color Emoji";
        icon = mkStrOption "Material Symbols Outlined";
        sizes = mkOption {
          type = types.submodule {
            options = mapListToAttrsWith ["terminal" "applications" "desktop"] (sizeOption 12);
          };
          default = {
            terminal = 12;
            applications = 12;
            desktop = 12;
          };
        };
      };

      os = {pkgs, ...}: {
        fonts.packages = with pkgs; [
          font-awesome
          maple-mono.NF-CN-unhinted
          inter
          monaspace
          noto-fonts-color-emoji
          material-symbols
        ];
      };
      nixos = {host, ...}: {
        fonts.fontconfig.defaultFonts = rec {
          monospace = [host.settings.base.fonts.mono];
          serif = sansSerif;
          sansSerif = [host.settings.base.fonts.sans];
        };
      };
    };
  };
}
