{ den, inputs, ... }:
{
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.nix.includes = with den.aspects.nix; [ disko ];

  den.aspects.nix.disko = {
    nixos = {
      imports = [
        inputs.disko.nixosModules.disko
      ];

      boot.supportedFilesystems = [
        "zfs"
      ];
    };
  };
}
