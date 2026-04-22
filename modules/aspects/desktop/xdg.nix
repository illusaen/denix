{
  den,
  ...
}:
{
  den.aspects.desktop.includes = [ den.aspects.xdg ];

  den.aspects.xdg = {
    hjem = {
      xdg.config.files = {
        "user-dirs.dirs".text = ''
          XDG_DOWNLOAD_DIR="$HOME/Downloads"
          XDG_PICTURES_DIR="$HOME/Pictures"
        '';
        "user-dirs.conf".text = "enabled=False";
      };
    };

    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ xdg-user-dirs ];
      };
  };
}
