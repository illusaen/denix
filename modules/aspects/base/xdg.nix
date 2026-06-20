{
  den.aspects.base.xdg = {
    nixos = {
      xdg.autostart.enable = true;
      environment.etc = {
        "xdg/user-dirs.defaults".text = ''
          DOWNLOAD="Downloads"
          PICTURES="Pictures"
        '';
        "xdg/user-dirs.conf".text = "enabled=True";
      };
    };
  };
}
