{
  den,
  lib,
  ...
}:
{
  den.ctx.host.includes = [
    den.aspects.cli
  ];

  den.aspects.cli = {
    includes = lib.attrValues den.aspects.cli._;

    _.packages = den.lib.perHost {
      vars.NIX_CONF = "${../../../.}";

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
  };
}
