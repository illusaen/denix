{
  den,
  ...
}:
{
  den.schema.host.includes = [ den.aspects.xdg ];
  den.aspects.xdg = {
    nixos.xdg.autostart.enable = true;

    hj = {
      xdg.config.files = {
        "user-dirs.dirs".text = ''
          XDG_DOWNLOAD_DIR="$HOME/Downloads"
          XDG_PICTURES_DIR="$HOME/Pictures"
        '';
        "user-dirs.conf".text = "enabled=False";
      };
    };
  };
}
