{
  den,
  ...
}:
{
  den.aspects.desktop._.xdg = den.lib.perHost {
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
