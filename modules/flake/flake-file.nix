{
  inputs,
  den,
  ...
}: {
  imports = [
    inputs.flake-file.flakeModules.dendritic or {}
  ];

  systems = builtins.attrNames den.hosts;

  flake-file = {
    prune-lock.enable = true;
    nixConfig = {
      abort-on-warn = false;
      accept-flake-config = true;
      auto-optimise-store = true;

      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos-cuda.org"
      ];

      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];

      extra-experimental-features = [
        "pipe-operator"
        "flakes"
        "nix-command"
      ];

      extra-deprecated-features = ["or-as-identifier"];

      lazy-trees = true;
      use-xdg-base-directories = true;
    };

    inputs = {
      den.url = "github:denful/den/main";
      flake-file.url = "github:denful/flake-file";
      import-tree.url = "github:denful/import-tree";
      flake-parts.url = "github:hercules-ci/flake-parts";
      flake-compat.url = "github:edolstra/flake-compat";
      flake-utils.url = "github:numtide/flake-utils";
      files.url = "github:mightyiam/files";
      gen-algebra.url = "github:sini/gen-algebra";

      nixpkgs-master.url = "github:NixOS/nixpkgs/master";
      nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      darwin = {
        url = "github:nix-darwin/nix-darwin/master";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };
      hjem = {
        url = "github:feel-co/hjem";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };
      scope-engine.url = "github:sini/scope-engine";
    };

    # Keep outputs in a separate file so write-flake preserves the
    # import-tree-based module loading instead of collapsing to ./modules.
    outputs = builtins.readFile ../../outputs.nix;
  };
}
