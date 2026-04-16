{
  den.aspects.gaming = {
    nixos.programs.steam.enable = true;

    mdLinux = {
      file.xdg_config."autostart/steam.desktop".text = ''
        [Desktop Entry]
        NotShowIn=niri
        Categories=Network;FileTransfer;Game;
        Exec=steam -silent
        GenericName=Game
        Icon=steam
        Keywords=gaming;game
        Name=Steam
        Type=Application
      '';
    };

    darwin =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ steam ];
      };
  };
}
