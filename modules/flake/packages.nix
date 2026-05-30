{ inputs, ... }:
{
  flake-file.inputs.pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
  imports = [ inputs.pkgs-by-name-for-flake-parts.flakeModule ];

  perSystem =
    { system, ... }:
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
    };
}
