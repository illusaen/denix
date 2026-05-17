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
      self,
      ...
    }:
    let
      inputs' = inputs // {
        self = self // {
          outPath = ./.;
        };
      };
    in
    flake-parts.lib.mkFlake { inputs = inputs'; } (import-tree ./modules);
in
with-inputs outputs
