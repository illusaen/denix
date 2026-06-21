{
  den.aspects.programs.image-editor = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [inkscape];
    };

    darwin = {
      homebrew.masApps."Pixelmator Pro" = 1289583905;
    };
  };
}
