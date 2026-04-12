{ lib, ... }:
{
  den.aspects.niri._.keybinds = {
    hm =
      { config, pkgs, ... }:
      {
        programs.niri.settings.binds =
          with config.lib.niri.actions;
          let
            sh = spawn "sh" "-c";
            # Spawn a single package's executable
            spawnPkg = pkg: spawn (lib.getExe pkg);
            # Spawn an executable wrapped in Kitty
            spawnTermPkg = pkg: spawnPkg pkgs.kitty (lib.getExe pkg);
          in
          lib.mapAttrs (_: value: lib.mkDefault value) (
            lib.attrsets.mergeAttrsList [
              {
                # Shortcuts
                "Mod+Escape".action = show-hotkey-overlay;
                "Mod+Tab".action = toggle-overview;
                "Mod+Q" = {
                  action = close-window;
                  repeat = false;
                };
              }
              {
                # Applications etc.
                "Alt+Shift+T".action = sh "kitten quick-access-terminal";
                "Mod+E".action = spawn "nemo"; # Use predefined nemo override pkg
                "Mod+G".action = spawnPkg pkgs.google-chrome;
                "Ctrl+Shift+Escape".action = spawnTermPkg pkgs.btop;
                "Mod+Shift+P".action = power-off-monitors;
                "Mod+Ctrl+Shift+Q".action = sh "pkill -9 winedevice.exe";
              }
              {
                # Fullscreen
                "Mod+F".action = maximize-column;
                "Mod+Shift+F".action = fullscreen-window;
                "Mod+Ctrl+F".action = toggle-windowed-fullscreen;
              }
              {
                # Screenshots
                "Alt+Shift+4".action.screenshot = {
                  show-pointer = false;
                };
              }
              (
                # Music keys
                let
                  audioControl = command: {
                    action = spawnPkg pkgs.playerctl command;
                    allow-when-locked = true;
                  };
                in
                {
                  "XF86AudioPlay" = audioControl "play-pause";
                  "XF86AudioNext" = audioControl "next";
                  "XF86AudioPrev" = audioControl "previous";
                }
              )
              {
                # Window actionsfw
                "Mod+Z".action = switch-preset-column-width;
                "Mod+Shift+Z".action = reset-window-height;
                "Mod+X".action = center-column;
                "Mod+Shift+X".action = center-visible-columns;
                "Mod+C".action = expand-column-to-available-width;
                "Mod+V".action = toggle-window-floating;
                "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;
              }
              # Focus navigation
              {
                "Mod+Up".action = focus-workspace-up;
                "Mod+Down".action = focus-workspace-down;
                "Mod+Left".action = focus-window-up-or-column-left;
                "Mod+Right".action = focus-window-down-or-column-right;
              }
              {
                "Mod+Shift+Up".action = move-column-to-workspace-up;
                "Mod+Shift+Down".action = move-column-to-workspace-down;
                "Mod+Shift+Left".action = move-column-left;
                "Mod+Shift+Right".action = move-column-right;

                # Move windows
                "Mod+Ctrl+Up".action = focus-monitor-up;
                "Mod+Ctrl+Down".action = focus-monitor-down;
                "Mod+Ctrl+Shift+Up".action = move-window-to-monitor-up;
                "Mod+Ctrl+Shift+Down".action = move-window-to-monitor-down;
              }
            ]
          );
      };
  };
}
