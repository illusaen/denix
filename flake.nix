# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = # flake-file reads this verbatim when regenerating flake.nix.
    # Use import-tree here because there is no modules/default.nix entrypoint.
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  nixConfig = {
    abort-on-warn = false;
    accept-flake-config = true;
    auto-optimise-store = true;
    extra-deprecated-features = [ "or-as-identifier" ];
    extra-experimental-features = [
      "pipe-operator"
      "pipe-operators"
      "flakes"
      "nix-command"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://install.determinate.systems"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
    lazy-trees = true;
    use-xdg-base-directories = true;
  };

  inputs = {
    base16.url = "github:SenchoPens/base16.nix";
    colmena.url = "github:zhaofengli/colmena";
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    den.url = "github:denful/den/main";
    den-diagram = {
      url = "github:denful/den-diagram";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    files.url = "github:mightyiam/files";
    flake-file.url = "github:denful/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-root.url = "github:srid/flake-root";
    gen-schema.url = "github:sini/gen-schema";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    import-tree.url = "github:denful/import-tree";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    opnix.url = "github:brizzbuzz/opnix";
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
    preservation.url = "github:nix-community/preservation";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
