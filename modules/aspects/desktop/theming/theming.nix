{
  lib,
  den,
  ...
}:
let
  inherit (lib) mkOption types;
  themingOption = mkOption {
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
  themingConfig = {
    iconTheme = {
      name = "Nordic-darker";
    };
    cursorTheme = {
      name = "Nordic-cursors";
      packageName = "nordic";
      size = 28;
    };
  };
in
{
  options.fleet.my.theming = themingOption;

  config = {
    fleet.my.theming = themingConfig;

    den.aspects.desktop =
      { host }:
      {
        includes = lib.optionals (host.class == "nixos") [ den.aspects.theming ];
      };

    den.aspects.theming = {
      fleet = {
        options.my.theming = themingOption;
        config.my.theming = themingConfig;
      };

      nixos =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            adw-gtk3
            adwaita-qt6
            nordic
          ];
        };
    };
  };
}
