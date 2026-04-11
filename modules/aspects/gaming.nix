{
  den.aspects.gaming = {
    nixos.programs.steam = {
      enable = true;
    };

    hmLinux =
      {
        pkgs,
        ...
      }:
      {
        xdg.autostart.entries = [
          (pkgs.makeDesktopItem {
            name = "steam";
            desktopName = "Steam";
            genericName = "Game Hub";
            icon = "steam";
            exec = "steam -silent";
            mimeTypes = [
              "x-scheme-handler/steam"
              "x-scheme-handler/steamlink"
            ];
            categories = [ "Game" ];
            keywords = [
              "steam"
              "gaming"
              "game"
            ];
            notShowIn = "niri";
          })
        ];
      };

    darwin =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ steam ];
      };
  };
}
