{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.chrome ];

  den.aspects.chrome = den.lib.perHost {
    darwin.homebrew.casks = [ "google-chrome@beta" ];
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ google-chrome ];
      };

    persistUser.directories = [ ".config/google-chrome" ];
  };
}
