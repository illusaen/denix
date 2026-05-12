{
  den.aspects.nix.xdg = {
    nixos.xdg.autostart.enable = true;

    provides.to-users.hjem.xdg.config.files = {
      "user-dirs.dirs".text = ''
        XDG_DOWNLOAD_DIR="$HOME/Downloads"
        XDG_PICTURES_DIR="$HOME/Pictures"
      '';
      "user-dirs.conf".text = "enabled=False";
    };
  };
}
