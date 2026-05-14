{
  den,
  lib,
  ...
}:
{
  den.policies.env-to-os =
    { host, ... }:
    (den.lib.policy.route {
      fromClass = "env";
      intoClass = host.class;
      path = [
        "environment"
        (if host.class == "nixos" then "sessionVariables" else "variables")
      ];
      guard =
        _:
        builtins.elem host.class [
          "nixos"
          "darwin"
        ];
    });

  den.schema.host.includes = [ den.policies.env-to-os ];
  den.classes.env.description = "Environment variables class";

  den.aspects.base.includes = with den.aspects.base; [ cli ];

  den.aspects.base.cli = {
    env.NIX_CONF = "~/Projects/denix";

    os =
      { config, pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          coreutils
          vim
          fzf
        ];

        environment.etc."dependencies.txt".text = lib.pipe config.environment.systemPackages (
          with builtins;
          [
            (lib.map (p: p.name))
            lib.lists.unique
            (sort lessThan)
            (concatStringsSep "\n")
          ]
        );
      };
  };
}
