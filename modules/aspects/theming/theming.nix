{
  den,
  lib,
  rootPath,
  config,
  ...
}: let
  inherit (lib) mkOption types optionalAttrs toSentenceCase;
  mkThemeOption = withSize: default:
    mkOption {
      type = types.submodule {
        options =
          {
            name = mkOption {type = types.str;};
            packageName = mkOption {type = types.str;};
          }
          // optionalAttrs withSize {size = mkOption {type = types.int;};};
      };
      inherit default;
    };
in {
  options.fleet.my.theming = mkOption {
    type = types.submodule {
      options = {
        iconTheme = mkThemeOption false {
          name = "WhiteSur";
          packageName = "whitesur-icon-theme";
        };
        gtkTheme = mkThemeOption false {
          name = "WhiteSur-${toSentenceCase config.fleet.my.base16.colorScheme}";
          packageName = "whitesur-gtk-theme";
        };
        cursorTheme = mkThemeOption true {
          name = "Nordic-cursors";
          packageName = "nordic";
          size = 28;
        };
      };
    };
  };

  config.den.aspects.theming = {
    includes = with den.aspects.theming; [
      gtk
      qt
    ];

    wrapper-packages = {fleet, ...}: {
      whitesur-gtk-theme = {
        imports = [(rootPath + /wrappers/whitesur-gtk-theme.nix)];
        font = fleet.my.fonts.sans;
      };
    };

    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        adw-gtk3
        adwaita-qt6
        nordic
        whitesur-icon-theme
      ];
    };
  };
}
