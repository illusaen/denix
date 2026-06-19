{
  inputs,
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
      ...
    }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      extended = pkgs.extend self.overlays.default;
    in
    {
      _module.args.pkgs = extended;

      # Flake outputs are evaluated outside the NixOS module graph, so they
      # need their own nixpkgs config for unfree packages.
      wrappers.pkgs = extended;
    };
}
