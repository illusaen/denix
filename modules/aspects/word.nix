{ den, ... }:
{
  den.aspects.word = den.lib.perHost {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          libreoffice-fresh
        ];
      };

    darwin = {
      homebrew.masApps."Microsoft Word" = 462054704;
    };
  };
}
