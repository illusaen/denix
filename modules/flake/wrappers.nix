{
  inputs,
  self,
  den,
  ...
}:
{
  flake-file.inputs.wrappers = {
    url = "github:BirdeeHub/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [ inputs.wrappers.flakeModules.wrappers ];
  flake.nixosModules = builtins.mapAttrs (_: v: v.install) self.wrappers;

  den.classes.wrappers.description = "Wrapper class for nix-wrapper-modules";
  den.policies.wrappers-to-flake =
    _:
    (den.lib.policy.route {
      fromClass = "wrapperPackages";
      intoClass = "flake";
      path = [
        "flake"
        "wrappers"
      ];
      adaptArgs = args: args // { osConfig = args.config; };
    });
  den.schema.host.includes = [ den.policies.wrappers-to-flake ];
}
