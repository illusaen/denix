{
  inputs,
  rootPath,
  withSystem,
  self,
  ...
}:
{
  flake-file.inputs.pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
  imports = [ inputs.pkgs-by-name-for-flake-parts.flakeModule ];

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
    { system, config, ... }:
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
      wrappers.pkgs = pkgs;
      pkgsDirectory = ../../packages/by-name;

      # manually called packages because they depend on wrapper packages
      packages = {
        rofi-calculator = pkgs.callPackage (rootPath + /packages/manual/rofi-calculator.nix) {
          rofi = config.packages.rofi-list;
        };
        rofi-launcher = pkgs.callPackage (rootPath + /packages/manual/rofi-launcher.nix) {
          rofi = config.packages.rofi-grid;
        };
        rofi-notifications = pkgs.callPackage (rootPath + /packages/manual/rofi-notifications.nix) {
          rofi = config.packages.rofi-actions;
        };
        rofi-power-menu = pkgs.callPackage (rootPath + /packages/manual/rofi-power-menu.nix) {
          rofi = config.packages.rofi-actions;
          inherit rootPath;
        };
      };
    };
}
