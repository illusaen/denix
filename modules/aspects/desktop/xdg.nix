{ den, ... }:
{
  den.aspects.desktop.includes = [ den.aspects.xdg ];

  den.aspects.xdg = {
    hm = {
      xdg = {
        enable = true;
        autostart.enable = true;
        mimeApps.enable = true;
        userDirs = {
          enable = true;
          documents = null;
          publicShare = null;
          templates = null;
          videos = null;
          setSessionVariables = false;
        };
      };
    };
  };
}
