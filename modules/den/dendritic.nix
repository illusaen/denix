{
  inputs,
  den,
  ...
}:
{
  imports = [
    # Define the top-level flake output schema explicitly so evaluation
    # does not depend on a flake-parts input being present in pins.
    inputs.flake-file.flakeModules.flakeless-parts
    inputs.den.flakeModule
  ];

  flake-file.inputs = {
    den.url = "github:denful/den/main";
    flake-file.url = "github:denful/flake-file";
    import-tree.url = "github:denful/import-tree";
    with-inputs.url = "github:denful/with-inputs";
    flake-parts.url = "github:hercules-ci/flake-parts";

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

  systems = builtins.attrNames den.hosts;
}
