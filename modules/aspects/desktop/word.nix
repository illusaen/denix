{ den, ... }:
{
  den.aspects.desktop.includes = with den.aspects.desktop; [ word ];
  den.aspects.desktop.word = {
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
