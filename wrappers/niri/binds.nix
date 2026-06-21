{
  "Alt+Shift+4" = _: {
    props.hotkey-overlay-title = "Screenshot";
    content.spawn-sh = "niri msg action screenshot show-pointer=false";
  };
  "Alt+Shift+T" = _: {
    props.hotkey-overlay-title = "Terminal";
    content.spawn-sh = "ndrop --app-id '^ndrop-foot$' --name foot -- footclient --app-id ndrop-foot";
  };
  "Mod+O" = _: {
    props.hotkey-overlay-title = "Obsidian";
    content.spawn-sh = "ndrop --app-id '^ndrop-obsidian$' --name obsidian -- ndrop-obsidian";
  };
  "Ctrl+Space" = _: {
    props.hotkey-overlay-title = "Launcher";
    content.spawn-sh = "rofi-launcher";
  };
  "Ctrl+Shift+Space" = _: {
    props.hotkey-overlay-title = "Notifications";
    content.spawn-sh = "rofi-notifications";
  };
  "Mod+Ctrl+Space" = _: {
    props.hotkey-overlay-title = "Power Menu";
    content.spawn-sh = "rofi-power-menu";
  };
  "Ctrl+Alt+Space" = _: {
    props.hotkey-overlay-title = "Calculator";
    content.spawn-sh = "rofi-calculator";
  };
  "Mod+Ctrl+Shift+Q" = _: {
    props.hotkey-overlay-title = "Kill Wine";
    content.spawn-sh = "pkill -9 winedevice.exe";
  };
  "Mod+Escape" = _: {
    props.hotkey-overlay-title = "Notification Center";
    content.spawn-sh = "swaync-client -t -sw";
  };
  "Mod+G" = _: {
    props.hotkey-overlay-title = "Google Chrome";
    content.spawn-sh = "google-chrome";
  };

  "Mod+Ctrl+B" = _: {
    props.hotkey-overlay-title = "Brightness +";
    content.spawn-sh = "monitor-brightness up";
  };
  "Mod+Ctrl+Shift+B" = _: {
    props.hotkey-overlay-title = "Brightness -";
    content.spawn-sh = "monitor-brightness down";
  };

  "XF86AudioLowerVolume" = _: {
    props = [
      {hotkey-overlay-title = "Vol Down";}
      {allow-when-locked = true;}
    ];
    content.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
  };
  "XF86AudioMute" = _: {
    props = [
      {hotkey-overlay-title = "Mute";}
      {allow-when-locked = true;}
    ];
    content.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
  };
  "XF86AudioNext" = _: {
    props = [
      {hotkey-overlay-title = "Playerctl next";}
      {allow-when-locked = true;}
    ];
    content.spawn-sh = "playerctl next";
  };
  "XF86AudioPlay" = _: {
    props = [
      {hotkey-overlay-title = "Playerctl play/pause";}
      {allow-when-locked = true;}
    ];
    content.spawn-sh = "playerctl play-pause";
  };
  "XF86AudioPrev" = _: {
    props = [
      {hotkey-overlay-title = "Playerctl prev";}
      {allow-when-locked = true;}
    ];
    content.spawn-sh = "playerctl previous";
  };
  "XF86AudioRaiseVolume" = _: {
    props = [
      {hotkey-overlay-title = "Vol Up";}
      {allow-when-locked = true;}
    ];
    content.spawn-sh = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
  };

  "Mod+C" = _: {
    props.hotkey-overlay-title = "Expand Column";
    content.expand-column-to-available-width = _: {};
  };
  "Mod+Z" = _: {
    props.hotkey-overlay-title = "Tog Preset Widths";
    content.switch-preset-column-width = _: {};
  };
  "Mod+F" = _: {
    props.hotkey-overlay-title = "Maximize";
    content.maximize-column = _: {};
  };
  "Mod+X" = _: {
    props.hotkey-overlay-title = "Center";
    content.center-column = _: {};
  };
  "Mod+Shift+V" = _: {
    props.hotkey-overlay-title = "Tog Focus Float/Tile";
    content.switch-focus-between-floating-and-tiling = _: {};
  };
  "Mod+V" = _: {
    props.hotkey-overlay-title = "Tog Floating";
    content.toggle-window-floating = _: {};
  };
  "Mod+Q" = _: {
    props.hotkey-overlay-title = "Close Window";
    props.repeat = false;
    content.close-window = _: {};
  };

  "Mod+Shift+P" = _: {
    props.hotkey-overlay-title = "Monitor ⏻";
    content.power-off-monitors = _: {};
  };
  "Mod+Tab" = _: {
    props.hotkey-overlay-title = "Overview";
    content.toggle-overview = _: {};
  };

  "Mod+Up" = _: {
    props.hotkey-overlay-title = "Focus Workspace ↑";
    content.spawn-sh = "niri-workspace up";
  };
  "Mod+Down" = _: {
    props.hotkey-overlay-title = "Focus Workspace ↓";
    content.spawn-sh = "niri-workspace down";
  };
  "Mod+Left" = _: {
    props.hotkey-overlay-title = "Focus Win ←";
    content.focus-window-up-or-column-left = _: {};
  };
  "Mod+Right" = _: {
    props.hotkey-overlay-title = "Focus Win →";
    content.focus-window-down-or-column-right = _: {};
  };

  "Mod+Ctrl+Up" = _: {
    props.hotkey-overlay-title = "Focus Mon ↑";
    content.focus-monitor-up = _: {};
  };
  "Mod+Ctrl+Down" = _: {
    props.hotkey-overlay-title = "Focus Mon ↓";
    content.focus-monitor-down = _: {};
  };
  "Mod+Ctrl+Left" = _: {
    props.hotkey-overlay-title = "Focus Mon ←";
    content.focus-monitor-left = _: {};
  };
  "Mod+Ctrl+Right" = _: {
    props.hotkey-overlay-title = "Focus Mon →";
    content.focus-monitor-right = _: {};
  };

  "Mod+Shift+Up" = _: {
    props.hotkey-overlay-title = "Move Win Work ↑";
    content.move-column-to-workspace-up = _: {};
  };
  "Mod+Shift+Down" = _: {
    props.hotkey-overlay-title = "Move Win Work ↓";
    content.move-column-to-workspace-down = _: {};
  };
  "Mod+Shift+Left" = _: {
    props.hotkey-overlay-title = "Move Win ←";
    content.move-column-left = _: {};
  };
  "Mod+Shift+Right" = _: {
    props.hotkey-overlay-title = "Move Win →";
    content.move-column-right = _: {};
  };

  "Mod+Ctrl+Shift+Up" = _: {
    props.hotkey-overlay-title = "Move Win Mon ↑";
    content.move-window-to-monitor-up = _: {};
  };
  "Mod+Ctrl+Shift+Down" = _: {
    props.hotkey-overlay-title = "Move Win Mon ↓";
    content.move-window-to-monitor-down = _: {};
  };
  "Mod+Ctrl+Shift+Left" = _: {
    props.hotkey-overlay-title = "Move Win Mon ←";
    content.move-window-to-monitor-left = _: {};
  };
  "Mod+Ctrl+Shift+Right" = _: {
    props.hotkey-overlay-title = "Move Win Mon →";
    content.move-window-to-monitor-right = _: {};
  };
}
