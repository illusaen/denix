{
  den.aspects.gaming = {
    nixos.programs.steam = {
      enable = true;
      gamescopeSession = {
        enable = true;
        steamArgs = [ "-silent" ];
      };
    };
    darwin =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ steam ];
      };
  };
}
