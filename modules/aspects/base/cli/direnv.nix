{
  den.aspects.base.cli.direnv = {
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
