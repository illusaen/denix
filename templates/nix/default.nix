{ inputs, ... }:
{
  imports = [ inputs.flake-file.flakeModules.flakeless-parts ];

  systems = [
    "aarch64-darwin"
    "x86_64-linux"
  ];

  flake-file.inputs = {
    flake-file.url = "github:vic/flake-file";
    import-tree.url = "github:vic/import-tree";
    with-inputs.url = "github:vic/with-inputs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
}
