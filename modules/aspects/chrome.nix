{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.chrome ];

  den.aspects.chrome = {
    darwin.homebrew.casks = [ "google-chrome@beta" ];
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ google-chrome ];
      };

    persistUser.directories = [ ".config/google-chrome" ];
  };
}
