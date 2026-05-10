let
  sources = import ./npins;
  with-inputs = import sources.with-inputs sources {
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    # uncomment on CI for local checkout
    # flake-file = import ./../../modules;
  };

  outputs =
    inputs@{
      flake-parts,
      import-tree,
      nixpkgs,
      ...
    }:
    let
      inputs' = inputs // {
        self = inputs.self // {
          outPath = ./.;
        };
      };
    in
    flake-parts.lib.mkFlake { inputs = inputs'; } (
      (import-tree ./modules)
      // {
        _module.args.helpers = import ./modules/den/_helpers.nix { inherit (nixpkgs) lib; };
      }
    );
in
with-inputs outputs
