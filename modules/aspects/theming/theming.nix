{
  den,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.fleet.my.theming = mkOption {
    type = types.submodule {
      options = {
        iconTheme = mkOption {
          type = types.submodule {
            options = {
              name = mkOption { type = types.str; };
              packageName = mkOption { type = types.str; };
            };
          };
        };
        gtkTheme = mkOption {
          type = types.submodule {
            options = {
              name = mkOption { type = types.str; };
              packageName = mkOption { type = types.str; };
            };
          };
        };
        cursorTheme = mkOption {
          type = types.submodule {
            options = {
              name = mkOption { type = types.str; };
              packageName = mkOption { type = types.str; };
              size = mkOption { type = types.int; };
            };
          };
        };
      };
    };
  };

  config = {
    fleet.my.theming = {
      iconTheme = {
        name = "WhiteSur";
        packageName = "whitesur-icon-theme";
      };
      gtkTheme = {
        name = "WhiteSur-Dark";
        packageName = "whitesur-gtk-theme";
      };
      cursorTheme = {
        name = "Nordic-cursors";
        packageName = "nordic";
        size = 28;
      };
    };

    den.aspects.theming.includes = with den.aspects.theming; [
      gtk
      qt
    ];

    den.aspects.theming.nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          adw-gtk3
          adwaita-qt6
          nordic
          whitesur-icon-theme
          local.dconf-to-nix
        ];
      };
  };
}
