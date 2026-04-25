{
  den,
  inputs,
  lib,
  ...
}:
let
  diskoClass =
    { class, aspect-chain }:
    den._.forward {
      each = lib.singleton class;
      fromClass = _: "disko";
      intoClass = _: "nixos"; # Disko only supports NixOS
      intoPath = _: [ ]; # Forwards into root
      fromAspect = _: lib.head aspect-chain;
    };
in
{
  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko-zfs = {
      url = "github:numtide/disko-zfs";
      inputs = {
        disko.follows = "disko";
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
  };

  den.ctx.host.includes = [
    den.aspects.disko
  ];

  den.aspects.disko = den.lib.perHost {
    includes = [ diskoClass ];

    nixos = {
      imports = [
        inputs.disko-zfs.nixosModules.default
        inputs.disko.nixosModules.disko
      ];

      disko.zfs.enable = true;

      boot.supportedFilesystems = [
        "zfs"
      ];
    };
  };
}
