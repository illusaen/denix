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
    control-center-margin-top = 56;
    control-center-margin-right = 12;
    control-center-width = 420;
    notification-window-width = 420;
    notification-icon-size = 48;
    notification-body-image-height = 100;
    notification-body-image-width = 180;
    timeout = 6;
    timeout-low = 3;
    timeout-critical = 0;
    fit-to-screen = false;
    control-center-exclusive-zone = false;
    widgets = [
      "mpris"
      "title"
      "volume"
      "backlight"
      "dnd"
      "notifications"
    ];
  };
  config."style.css".path = pkgs.replaceVars ./style.css {
    inherit (config.colors)
      base00
      base02
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
