{
  inputs,
  self,
  den,
  lib,
  ...
}:
{
  imports = [ inputs.wrappers.flakeModules.wrappers ];

  options.wrappers = lib.mkOption { type = lib.types.raw; };

  config = {
    flake-file.inputs.wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    flake.nixosModules = builtins.mapAttrs (_: v: v.install) self.wrappers;

    den.classes.wrapper-packages = { };
    den.policies.wrapper-packages-to-flake-parts = _: [
      (den.lib.policy.route {
        fromClass = "wrapper-packages";
        intoClass = "flake";
        path = [
          "flake"
          "wrappers"
        ];
        adaptArgs = { config, ... }: config.allModuleArgs;
      })
    ];

    den.schema.host.includes = [
      den.policies.wrapper-packages-to-flake-parts
    ];
  };
}
