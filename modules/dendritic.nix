{
  inputs,
  den,
  lib,
  ...
}:
{
  imports = [
    (inputs.flake-file.flakeModules.flakeless-parts or { })
    (inputs.den.flakeModules.dendritic or { })
    inputs.flake-file.flakeModules.npins
  ];

  flake-file.inputs = {
    den.url = "github:vic/den";
    flake-file.url = "github:vic/flake-file";
    import-tree.url = "github:vic/import-tree";
    with-inputs = {
      url = "github:vic/with-inputs";
      flake = false;
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  systems = lib.attrNames den.hosts;
}
