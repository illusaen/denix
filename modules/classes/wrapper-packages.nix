{
  inputs,
  self,
  den,
  ...
}:
{
  flake-file.inputs.wrappers = {
    url = "github:BirdeeHub/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  imports = [ inputs.wrappers.flakeModules.wrappers ];
  flake.nixosModules = builtins.mapAttrs (_: v: v.install) self.wrappers;

  den.classes.wrapper-packages = { };
  den.policies.wrapper-packages-to-flake-parts = _: [
    (den.lib.policy.route {
      fromClass = "devshell";
      intoClass = "flake-parts";
      path = [
        "wrappers"
      ];
      adaptArgs = { config, ... }: config.allModuleArgs;
    })
  ];

  den.schema.flake-parts.includes = [
    den.policies.wrapper-packages-to-flake-parts
  ];
}
