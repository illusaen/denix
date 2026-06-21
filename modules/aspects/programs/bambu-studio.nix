{
  den.aspects.programs.bambu-studio = {
    nixos = {pkgs, ...}: {environment.systemPackages = with pkgs; [bambu-studio];};
    darwin.homebrew.casks = ["bambu-studio"];
  };
}
