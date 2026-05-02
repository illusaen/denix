{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.image-editor ];
  den.aspects.image-editor = den.lib.perHost {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ inkscape ];
      };

    darwin = {
      homebrew.masApps."Pixelmator Pro" = "1289583905";
    };
  };
}
