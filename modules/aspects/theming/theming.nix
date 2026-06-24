{
  den,
  lib,
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
    settings = {host, ...}: let
      inherit (host.settings.base.base16) colorScheme;
    in {
      iconTheme = mkThemeOption false {
        name = "WhiteSur";
        packageName = "whitesur-icon-theme";
      };
      gtkTheme = mkThemeOption false {
        name = "WhiteSur-${lib.toSentenceCase colorScheme}";
        packageName = "whitesur-gtk-theme";
      };
      qtTheme =
        mkThemeOption false
        {
          name = "WhiteSur${
            if colorScheme == "dark"
            then "Dark"
            else ""
          }";
          packageName = "whitesur-kde-theme";
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

    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        nordic
        whitesur-icon-theme
        local.whitesur-gtk-theme
        local.whitesur-kde-theme
      ];
    };
  };
}
