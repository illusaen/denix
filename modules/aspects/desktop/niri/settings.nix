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

      prefer-no-csd = true;

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

      hotkey-overlay.skip-at-startup = true;

      layout = {
        border.enable = false;
        preset-column-widths = [
          { proportion = 1. / 3.; }
          { proportion = 2. / 3.; }
          { proportion = 1. / 5.; }
        ];
        center-focused-column = "on-overflow";
        always-center-single-column = true;
        default-column-width.proportion = 1. / 3.;
      };

      workspaces = {
        code.open-on-output = "LG Electronics LG ULTRAGEAR+ 508RMWVJR505";
        gaming.open-on-output = "LG Electronics LG ULTRAGEAR+ 508RMWVJR505";
        chat.open-on-output = "Philips Consumer Electronics Company PHL 288E2 UK52215001852";
      };

      debug = {
        wait-for-frame-completion-before-queueing = [ ];
      };
    };
  };
}
