{
  inputs,
  self,
  ...
}:
{
  flake-file.inputs.wrappers = {
    url = "github:BirdeeHub/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [ inputs.wrappers.flakeModules.wrappers ];
  flake.nixosModules = builtins.mapAttrs (_: v: v.install) self.wrappers;
}
