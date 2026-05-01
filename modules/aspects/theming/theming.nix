{
  den,
  lib,
  ...
}:
{
  flake-file.inputs = {
    base16.url = "github:SenchoPens/base16.nix";
  };

  den.aspects.theming = {
    includes = lib.attrValues den.aspects.theming._;

    os =
      {
        lib,
        helpers,
        ...
      }:
      let
        inherit (lib) mkOption types;
        inherit (helpers) mkThemeType;
      in
      {
        options.myLib.theming = lib.mkOption {
          type = types.submodule {
            options = {
              iconTheme = mkOption {
                type = mkThemeType { };
              };
              cursorTheme = mkOption {
                type = mkThemeType { hasSize = true; };
              };
            };
          };
        };
      };

    nixos =
      { pkgs, ... }:
      {
        myLib.theming = {
          iconTheme = {
            name = "Nordic-darker";
            package = pkgs.nordic;
          };
          cursorTheme = {
            name = "Nordic-cursors";
            package = pkgs.nordic;
            size = 28;
          };
        };
        environment.systemPackages = with pkgs; [
          adw-gtk3
          adwaita-qt6
          dracula-icon-theme
          nordic
        ];
      };
  };
}
