{ den, ... }:
{
  den.aspects.cli._.direnv = den.lib.perHost {
    # Temporary workaround: https://github.com/nixos/nixpkgs/issues/513019
    darwin = {
      nixpkgs.overlays = [
        (_: prev: {
          direnv = prev.direnv.overrideAttrs (_: {
            doCheck = false;
          });
        })
      ];
    };

    os = {
      programs.direnv = {
        enable = true;
        silent = true;
        nix-direnv.enable = true;
        settings = {
          hide_env_diff = true;
          whitelist.prefix = [ "~/Projects" ];
        };
      };
    };
  };
}
