{
  den.aspects.niri._.rules = {
    hm.programs.niri.settings.window-rules = [
      {
        # Relocate Steam notifications to the bottom right of the screen
        matches = [
          {
            app-id = "steam";
            title = "^notificationtoasts_\\d+_desktop$";
          }
        ];
        default-floating-position = {
          x = 2;
          y = 2;
          relative-to = "bottom-right";
        };
        open-focused = false;
      }
      {
        # Floating file-roller
        matches = [
          { title = "^(.*)(o|O|s|S)(pen|ave) (f|F|a|a)(ile|s)(.*)$"; }
          { app-id = "^org.pulseaudio.pavucontrol$"; }
          { app-id = "^(.*)blueman-manager(.*)$"; }
        ];
        open-floating = true;
        max-height = 800;
        max-width = 1280;
      }
      {
        # VRR allowlist
        matches = [
          { app-id = "^steam_app.*"; } # Most steam games
        ];
        open-focused = true;
      }
      {
        # Rounded corners
        geometry-corner-radius =
          let
            radius = 8.0;
          in
          {
            top-left = radius;
            top-right = radius;
            bottom-left = radius;
            bottom-right = radius;
          };
        clip-to-geometry = true;
      }
      {
        # Shadow behind windows
        matches = [
          { app-id = "^kitty$"; }
        ];
        shadow = {
          draw-behind-window = true;
          color = "#000000B3";
        };
      }
      {
        # 90% Transparent windows + Shadow behind
        matches = [
          { is-floating = true; }
          { app-id = "^vesktop$"; }
          { app-id = "^nemo$"; }
        ];
        opacity = 0.9;
        draw-border-with-background = false;
        shadow = {
          draw-behind-window = true;
          color = "#000000B3";
        };
      }
      {
        matches = [
          { app-id = "^vesktop$"; }
          { app-id = "^Element$"; }
        ];
        open-on-workspace = "chat";
      }
      {
        matches = [
          { app-id = "^^steam.*$"; }
        ];
        open-on-workspace = "gaming";
      }
      {
        matches = [
          { at-startup = true; }
          { app-id = "^google-chrome$"; }
        ];
        open-on-workspace = "chat";
      }
      {
        matches = [
          { title = "^Viking Rise Steam$"; }
        ];
        default-column-width = {
          fixed = 4164;
        };
        min-width = 4164;
        open-on-workspace = "gaming";
      }
      {
        matches = [
          { app-id = "^code$"; }
        ];
        open-on-workspace = "code";
      }
    ];
  };
}
