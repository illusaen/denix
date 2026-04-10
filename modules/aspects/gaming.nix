{
  den.aspects.gaming = {
    nixos.programs.steam = {
      enable = true;
      gamescopeSession = {
        enable = true;
        steamArgs = [ "-silent" ];
      };
    };

    hmLinux =
      { osConfig, ... }:
      {
        xdg.autostart.entries = [ "${osConfig.programs.steam.package}/share/applications/steam.desktop" ];
      };

    darwin =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ steam ];
      };
  };
}
