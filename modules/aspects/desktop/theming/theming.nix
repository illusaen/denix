{
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
            options.name = mkOption { type = types.str; };
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
        name = "Nordic-darker";
      };
      cursorTheme = {
        name = "Nordic-cursors";
        packageName = "nordic";
        size = 28;
      };
    };

    den.aspects.theming.nixos =
      { pkgs, self', ... }:
      {
        environment.systemPackages = with pkgs; [
          adw-gtk3
          adwaita-qt6
          nordic
          self'.packages.dconf-to-nix
        ];
      };
  };
}
