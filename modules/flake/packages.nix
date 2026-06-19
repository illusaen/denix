{
  inputs,
  rootPath,
  withSystem,
  self,
  ...
}:
{
  flake.overlays.default =
    _final: prev:
    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:
      {
        local = config.packages;
      }
    );

  den.default = {
    nixos.nixpkgs.overlays = [ self.overlays.default ];
    darwin.nixpkgs.overlays = [ self.overlays.default ];
  };

  perSystem =
    {
      system,
      config,
      ...
    }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      _module.args.pkgs = pkgs;

      # Flake outputs are evaluated outside the NixOS module graph, so they
      # need their own nixpkgs config for unfree packages.
      wrappers.pkgs = pkgs.extend self.overlays.default;

      # manually called packages because they depend on wrapper packages
      packages = {
        fish-vendor-functions = pkgs.callPackage (
          rootPath + /packages/by-name/fish-vendor-functions/package.nix
        ) { };
        rofi-calculator = pkgs.callPackage (rootPath + /packages/manual/rofi-calculator.nix) {
          rofi = config.packages.rofi;
        };
        rofi-launcher = pkgs.callPackage (rootPath + /packages/manual/rofi-launcher.nix) {
          rofi = config.packages.rofi;
        };
        rofi-notifications = pkgs.callPackage (rootPath + /packages/manual/rofi-notifications.nix) {
          rofi = config.packages.rofi;
        };
        rofi-power-menu = pkgs.callPackage (rootPath + /packages/manual/rofi-power-menu.nix) {
          rofi = config.packages.rofi;
          swaylock = config.packages.swaylock;
        };
        whitesur-gtk-theme = pkgs.callPackage (
          rootPath + /packages/by-name/whitesur-gtk-theme/package.nix
        ) { };
      };
    };
}
