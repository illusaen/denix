{
  inputs,
  self,
  den,
  lib,
  ...
}:
{
  flake-file.inputs.wrappers = {
    url = "github:BirdeeHub/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [ inputs.wrappers.flakeModules.wrappers ];
  flake.nixosModules = builtins.mapAttrs (_: v: v.install) self.wrappers;

  den.classes.flake-config.description = "Flake-level configuration";
  den.policies.flake-config-to-flake =
    _:
    den.lib.policy.route {
      fromClass = "flake-config";
      intoClass = "flake";
      path = [ "flake" ];
      instantiate =
        { modules, ... }:
        removeAttrs
          (lib.evalModules {
            modules = [
              { config._module.freeformType = lib.types.lazyAttrsOf lib.types.raw; }
            ]
            ++ modules;
          }).config
          [ "_module" ];
    };
  den.schema.flake-system.includes = [ den.policies.flake-config-to-flake ];

  den.quirks.wrapper-packages.description = "Wrapper class for nix-wrapper-modules";
  den.policies.collect-wrapper-packages =
    _:
    let
      inherit (den.lib.policy) pipe;
    in
    [
      (pipe.from "wrapper-packages" [
        (pipe.collect (_: true))
      ])
    ];
  den.schema.host.includes = [ den.policies.collect-wrapper-packages ];

  den.default.flake-config =
    { wrapper-packages, ... }:
    {
      wrappers = builtins.foldl' lib.recursiveUpdate { } wrapper-packages;
    };
}
