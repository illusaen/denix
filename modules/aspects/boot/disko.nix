{
  inputs,
  rootPath,
  ...
}: {
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.boot.disko = {
    nixos = {host, ...}: {
      imports = [
        inputs.disko.nixosModules.disko
        (import "${rootPath}/hosts/${host.name}/disko.nix" {
          inherit (host.preservation) disk persistMount rollbackSnapshot;
        })
      ];

      boot.supportedFilesystems = [
        "zfs"
      ];
    };
  };
}
