{
  den,
  lib,
  rootPath,
  ...
}: let
  inherit (lib) mkOption types optionalAttrs;
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
  config.den.aspects.theming = {
    settings = {
      iconTheme = mkThemeOption false {
        name = "WhiteSur";
        packageName = "whitesur-icon-theme";
      };
      gtkTheme = mkThemeOption false {
        name = "WhiteSur-Dark";
        packageName = "whitesur-gtk-theme";
      };
      cursorTheme = mkThemeOption true {
        name = "Nordic-cursors";
        packageName = "nordic";
        size = 28;
      };
    };

    includes = with den.aspects.theming; [
      gtk
      qt
    ];

    wrapper-packages = {host, ...}: {
      whitesur-gtk-theme = {
        imports = [(rootPath + /wrappers/whitesur-gtk-theme.nix)];
        font = host.settings.base.fonts.sans;
        fontSize = host.settings.base.fonts.sizes.applications;
      };
    };

    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        adwaita-qt6
        nordic
        whitesur-icon-theme
      ];
    };
  };
}
