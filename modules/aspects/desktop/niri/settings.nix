{
  den.aspects.niri._.settings = {
    hm.programs.niri.settings = {
      environment = {
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        QT_QPA_PLATFORMTHEME = "qt5ct";
        QT_QPA_PLATFORM = "wayland";
        GDK_BACKEND = "wayland,x11,*";
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "niri";
        NIXOS_OZONE_WL = "1";
      };

      input = {
        mouse = {
          scroll-factor = 1.1;
          scroll-button = 274;
          scroll-method = "on-button-down";
          middle-emulation = true;
        };

        warp-mouse-to-focus.enable = true;

        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "20%";
        };
      };
    };
  };
}
