{ den, ... }:
{
  den.schema.host.includes = [ den.aspects.image-editor ];
  den.aspects.image-editor = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ inkscape ];
      };

    darwin = {
      homebrew.masApps."Pixelmator Pro" = 1289583905;
    };
  };
}
