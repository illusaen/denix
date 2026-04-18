{ den, ... }:
{
  den.aspects.cli._.direnv = den.lib.perHost {
    persistUser.directories = [
      ".local/share/direnv"
    ];

    os = {
      programs.direnv = {
        enable = true;
        silent = true;
        nix-direnv.enable = true;
        settings = {
          hide_env_diff = true;
          whitelist.prefix = [ "$HOME/Projects" ];
        };
      };
    };
  };
}
