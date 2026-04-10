{ lib, ... }:
{
  den.aspects.noctalia =
    { host, ... }:
    {
      hm.programs.noctalia-shell.settings = {
        ui = {
          # UI
          tooltipsEnabled = true;
          boxBorderEnabled = false;
          translucentWidgets = true;
          panelBackgroundOpacity = lib.mkForce 0.9;
          scrollbarAlwaysVisible = true;
          panelsAttachedToBar = true;
          settingsPanelMode = "attached";
          settingsPanelSideBarCardStyle = false;
          # Fonts
          # fontDefault = host.fonts.sans.name;
          fontFixed = host.fonts.mono.name;
          fontDefaultScale = 1;
          fontFixedScale = 1;
        };

        # ---Noctalia calendar settings---
        calendar = {
          cards = [
            {
              enabled = true;
              id = "calendar-header-card";
            }
            {
              enabled = true;
              id = "calendar-month-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
          ];
        };

        # ---Noctalia control center settings---
        controlCenter = {
          position = "close_to_bar_button";
          diskPath = "/";
          shortcuts = {
            left = [
              {
                id = "Network";
              }
              {
                id = "Bluetooth";
              }
              {
                id = "WallpaperSelector";
              }
              {
                id = "NoctaliaPerformance";
              }
            ];
            right = [
              {
                id = "Notifications";
              }
              {
                id = "PowerProfile";
              }
              {
                id = "KeepAwake";
              }
              {
                id = "NightLight";
              }
            ];
          };
          cards = [
            {
              enabled = true;
              id = "profile-card";
            }
            {
              enabled = false;
              id = "shortcuts-card";
            }
            {
              enabled = true;
              id = "audio-card";
            }
            {
              enabled = false;
              id = "brightness-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
            {
              enabled = true;
              id = "media-sysmon-card";
            }
          ];
        };

        # ---Noctalia on-screen display settings---
        osd = {
          enabled = true; # UI popups when changing volume/brightness etc
          location = "top_right";
          autoHideMs = 2000;
          overlayLayer = true;
          backgroundOpacity = lib.mkForce 1;
          enabledTypes = [
            0 # Output volume
            1 # Input volume
            2 # Brightness
            # 3  # Lock keys (caps/num lock etc)
          ];
          # Only show on specific monitors?
          monitors = [ ];
        };

        # ---Noctalia colour scheme settings---
        colorSchemes = {
          # Dark mode
          darkMode = true;
          schedulingMode = "off";
          manualSunrise = "06:30";
          manualSunset = "18:30";
          # Wallpaper colour settings
          useWallpaperColors = false;
          generationMethod = "tonal-spot";
          monitorForColors = ""; # Use a specific monitor for colour detection
          # Manual colour scheme
          predefinedScheme = "Rosey AMOLED";
        };

        # ---Noctalia night light settings---
        nightLight = {
          enabled = false;
          forced = false;
          autoSchedule = true;
          nightTemp = "4000";
          dayTemp = "6500";
          manualSunrise = "06:30";
          manualSunset = "18:30";
        };

        # ---Noctalia desktop widget settings---
        desktopWidgets = {
          enabled = false;
          gridSnap = false;
          gridSnapScale = false;
          overviewEnabled = true; # Show in overview
          monitorWidgets = [ ];
        };

        # ---Noctalia template settings---
        templates = {
          enableUserTheming = false;
          activeTemplates = [ ];
        };
      };
    };
}
