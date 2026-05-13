{
  den,
  inputs,
  ...
}:
{
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.policies.disko-to-nixos =
    _:
    (den.lib.policy.route {
      fromClass = "disko";
      intoClass = "nixos";
      path = [ ];
    });

  den.schema.host.includes = [
    den.policies.disko-to-nixos
  ];

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
