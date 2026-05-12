{
  helpers,
  lib,
  den,
  ...
}:
{
  flake-file.inputs.base16.url = "github:SenchoPens/base16.nix";

  den.aspects.desktop =
    { host }:
    {
      includes = lib.optionals (host.class == "nixos") [ den.aspects.theming ];
    };

  den.aspects.theming = {
    os =
      let
        inherit (lib) mkOption;
        inherit (helpers) mkThemeType mkSubmoduleOption;
      in
      {
        options.myLib.theming = mkSubmoduleOption {
          iconTheme = mkOption {
            type = mkThemeType { };
          };
          cursorTheme = mkOption {
            type = mkThemeType { hasSize = true; };
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
          nordic
        ];
      };
  };
}
