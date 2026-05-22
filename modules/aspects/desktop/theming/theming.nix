{
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
    flake-config =
      {
        myLib,
        ...
      }:
      let
        inherit (lib) mkOption types;
        inherit (myLib) mkSubmoduleOption;
      in
      {
        options.my.theming = mkSubmoduleOption {
          iconTheme = mkOption {
            type = types.submodule {
              options.name = mkOption { type = types.str; };
            };
          };
          cursorTheme = types.submodule {
            options = {
              name = mkOption { type = types.str; };
              packageName = mkOption { type = types.str; };
              size = mkOption { type = types.int; };
            };
          };
        };
        config.my.theming = {
          iconTheme = {
            name = "Nordic-darker";
          };
          cursorTheme = {
            name = "Nordic-cursors";
            packageName = "nordic";
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
