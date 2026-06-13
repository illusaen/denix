{
  wlib,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ wlib.modules.default ];
  options = {
    font = lib.mkOption { type = lib.types.str; };
    colors = lib.mkOption { type = lib.types.raw; };
    settings = lib.mkOption {
      type = wlib.types.structuredValueWith { typeName = "JSON"; };
      default = { };
      description = ''
        SwayNC configuration settings.
      '';
    };
    configFile = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.path = config.constructFiles.generatedConfig.path;
      default.content = "";
      description = ''
        SwayNC configuration settings file.
      '';
    };
    "style.css" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.path = config.constructFiles.generatedStyle.path;
      default.content = "";
      description = "CSS style for SwayNC.";
    };
  };

  config.settings = {
    positionX = "right";
    positionY = "top";
    layer = "overlay";
    layer-shell = true;
    cssPriority = "application";
    control-center-width = 520;
    control-center-margin-top = 0;
    control-center-margin-bottom = 0;
    control-center-margin-right = 0;
    control-center-margin-left = 0;
    notification-2fa-action = true;
    notification-inline-replies = false;
    notification-window-width = 380;
    notification-icon-size = 48;
    notification-body-image-height = 240;
    notification-body-image-width = 240;
    timeout = 8;
    timeout-low = 4;
    timeout-critical = 0;
    fit-to-screen = true;
    keyboard-shortcuts = true;
    image-visibility = "when-available";
    transition-time = 150;
    hide-on-clear = true;
    hide-on-action = true;
    script-fail-notify = true;
    widgets = [
      "mpris"
      "volume"
      "title"
      "notifications"
      "buttons-grid"
    ];
    widget-config = {
      title = {
        text = "Notifications";
        clear-all-button = true;
        button-text = "Clear";
      };
      mpris = {
        image-size = 80;
        image-radius = 10;
      };
      volume = {
        label = "";
        step = 5;
      };
      backlight = {
        label = "󰃞";
        step = 5;
      };
      buttons-grid.actions = [
        {
          label = "󰂛";
          command = "${placeholder "out"}/bin/swaync-client -d";
          tooltip = "DND";
        }
        {
          label = "";
          command = "${lib.getExe pkgs.pavucontrol}";
          tooltip = "Audio";
        }
        {
          label = "";
          command = "${pkgs.blueman}/bin/blueman-manager";
          tooltip = "Bluetooth";
        }
        {
          label = "";
          command = "${lib.getExe pkgs.local.swaylock}";
          tooltip = "Lock";
        }
        {
          label = "󰜉";
          command = "reboot";
          tooltip = "Reboot";
        }
        {
          label = "⏻";
          command = "shutdown now";
          tooltip = "Power off";
        }
      ];
    };
  };
  config."style.css".path = pkgs.replaceVars ./style.css {
    inherit (config.colors)
      base00
      base03
      base04
      base05
      base07
      base09
      ;
    inherit (config) font;
  };
  config.package = pkgs.swaynotificationcenter;
  config.flags = {
    "--config" = config.configFile.path;
    "--style" = config."style.css".path;
  };
  config.constructFiles.generatedStyle = {
    content = config.configFile.content or "";
    relPath = "${config.binName}-style.css";
  };
  config.constructFiles.generatedConfig = {
    content =
      if config.configFile.content or "" != "" then
        config.configFile.content
      else
        builtins.toJSON config.settings;
    relPath = "${config.binName}-config.json";
  };
}
