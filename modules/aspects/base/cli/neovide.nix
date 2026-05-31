{ den, ... }:
{
  den.aspects.base.cli.includes = [ den.aspects.base.cli.neovide ];
  den.aspects.base.cli.neovide = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ neovide ];
      };
  };
}
