{ den, ... }:
{
  den.aspects.niri._.rules = den.lib.perUser {
    homeManager = {
      programs.niri.settings.window-rules = [
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
          matches = [ { app-id = "^org.gnome.FileRoller$"; } ];
          open-floating = true;
          max-height = 600;
          max-width = 900;
        }
        {
          # VRR allowlist
          matches = [
            { app-id = "^steam_app.*"; } # Most steam games
          ];
          variable-refresh-rate = true;
          open-focused = true;
        }
        {
          # Rounded corners
          geometry-corner-radius =
            let
              radius = 18.0;
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
          ];
          opacity = 0.9;
          draw-border-with-background = false;
          shadow = {
            draw-behind-window = true;
            color = "#000000B3";
          };
        }
        {
          # 80% Transparent windows + Shadow behind
          matches = [
            { is-floating = true; }
            { app-id = "^nemo$"; }
          ];
          opacity = 0.8;
          draw-border-with-background = false;
          shadow = {
            draw-behind-window = true;
            color = "#000000B3";
          };
        }
      ];
    };
  };
}
