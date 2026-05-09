_: {
  den.aspects.word = {
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
