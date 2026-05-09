{ den, inputs, ... }:
{
  flake-file.inputs = {
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.schema.host.includes = [ den.aspects.nix-index ];

  den.aspects.nix-index = {
    os.programs.nix-index-database.comma.enable = true;

    nixos.imports = [ inputs.nix-index-database.nixosModules.default ];

    darwin.imports = [ inputs.nix-index-database.darwinModules.nix-index ];
  };
}
