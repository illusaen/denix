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
