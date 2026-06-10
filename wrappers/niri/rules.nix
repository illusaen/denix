{
  layer-rules = [
    {
      matches = [ { namespace = "kitty-quick-access"; } ];
      background-effect.xray = false;
    }
    {
      matches = [ { namespace = "^dms:desktop-widget:.*$"; } ];
      background-effect.blur = true;
    }
    {
      matches = [ { namespace = "^quickshell$"; } ];
      place-within-backdrop = true;
    }
  ];

  window-rules = [
    {
      geometry-corner-radius = 16;
      clip-to-geometry = true;
      tiled-state = true;
      popups = {
        opacity = 0.92;
        background-effect.blur = true;
      };
    }
    {
      matches = [ { is-floating = true; } ];
      shadow = {
        draw-behind-window = true;
        color = "#000000B3";
      };
      opacity = 0.96;
      background-effect.blur = true;
    }
    {
      matches = [ { is-active = false; } ];
      opacity = 0.94;
      background-effect.blur = true;
    }
    {
      matches = [ { app-id = "org.quickshell$"; } ];
      open-floating = true;
    }
    {
      matches = [
        { app-id = "^(.*)(o|O|s|S)(pen|ave) (f|F|a|a)(ile|s)(.*)"; }
        { app-id = "org.pulseaudio.pavucontrol"; }
        { app-id = "^(.*)blueman-manager(.*)$"; }
        { app-id = "xdg-desktop-portal-gtk"; }
        { app-id = "xdg-desktop-portal-gnome"; }
        { app-id = "nemo"; }
      ];
      open-floating = true;
      max-width = 1800;
      max-height = 1200;
    }
    {
      matches = [
        { app-id = "mpv"; }
        { app-id = "youtube-music-desktop-app"; }
      ];
      open-on-workspace = "music";
      default-column-width.proportion = 1.0;
    }
    {
      matches = [
        { app-id = "code"; }
        { app-id = "google-chrome"; }
      ];
      open-on-workspace = "code";
    }
    {
      matches = [
        { app-id = "vesktop"; }
        { app-id = "discord"; }
        { app-id = "Element"; }
        { app-id = "org.telegram.desktop"; }
      ];
      open-on-workspace = "chat";
    }
    {
      matches = [
        { title = "Viking Rise Steam"; }
        { app-id = "steam.*"; }
      ];
      open-on-workspace = "gaming";
    }
    {
      matches = [
        { title = "Viking Rise Steam"; }
      ];
      min-width = 4192;
    }
    {
      matches = [
        {
          app-id = "steam";
          title = "^notificationtoasts_\\d+_desktop$";
        }
      ];
      open-focused = false;
      default-floating-position = _: {
        props = {
          relative-to = "bottom-right";
          x = 2;
          y = 2;
        };
      };
    }
  ];
}
