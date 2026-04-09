{
  den,
  inputs,
  lib,
  ...
}:
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
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  den.ctx.host.includes = [
    den.aspects.disko
  ];

  den.aspects.disko = {
    includes = lib.attrValues den.aspects.disko._;

    _.diskoClass = den.lib.perHost (
      { class, aspect-chain }:
      den._.forward {
        each = lib.singleton class;
        fromClass = _: "disko";
        intoClass = _: "nixos"; # Disko only supports NixOS
        intoPath = _: [ ]; # Forwards into root
        fromAspect = _: lib.head aspect-chain;
      }
    );

    _.core = den.lib.perHost {
      nixos = {
        imports = [
          inputs.disko-zfs.nixosModules.default
          inputs.disko.nixosModules.disko
        ];

        boot.supportedFilesystems = [
          "zfs"
        ];
      };
    };
  };
}
