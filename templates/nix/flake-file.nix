{ inputs, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.dendritic or { }
  ];

  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];

  flake-file = {
    inputs = {
      flake-file.url = "github:denful/flake-file";
      import-tree.url = "github:denful/import-tree";
      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs-unstable";
      };
      nixpkgs.follows = "nixpkgs-unstable";
      nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    outputs = ''
      inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./nix)
    '';
  };
}
