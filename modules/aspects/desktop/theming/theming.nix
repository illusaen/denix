{
  lib,
  den,
  inputs,
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
    flake-config =
      {
        myLib,
        system,
        ...
      }:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        inherit (lib) mkOption;
        inherit (myLib) mkThemeType mkSubmoduleOption;
      in
      {
        options.my.theming = mkSubmoduleOption {
          iconTheme = mkOption {
            type = mkThemeType { };
          };
          cursorTheme = mkOption {
            type = mkThemeType { hasSize = true; };
          };
        };
        config.my.theming = {
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
}
