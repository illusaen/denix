{ den, ... }:
{
  den.aspects.desktop.includes = with den.aspects.desktop; [ image-editor ];

  den.aspects.desktop.image-editor = {
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
