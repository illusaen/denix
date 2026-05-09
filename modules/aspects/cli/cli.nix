{
  den,
  lib,
  ...
}:
{
  den.schema.host.includes = [
    den.aspects.cli
  ];

  den.quirks.env.description = "Environment variables";
  den.policies.merge-env =
    _:
    let
      inherit (den.lib.policy) pipe;
    in
    [
      (pipe.from "env" [
        (pipe.fold (acc: n: lib.recursiveUpdate acc n) { })
      ])
    ];

  den.aspects.cli = {
    includes = lib.attrValues den.aspects.cli._ ++ [ den.policies.merge-env ];

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

    nixos =
      { env, ... }:
      {
        environment.sessionVariables = lib.head env;
      };

    darwin =
      { env, ... }:
      {
        environment.variables = lib.head env;
      };
  };
}
