{
  wlib,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ wlib.wrapperModules.waybar ];
  options = {
    scheme = lib.mkOption {
      type = lib.types.raw;
      description = "base16 scheme with hashtag";
    };
    font = lib.mkOption {
      type = lib.types.submodule {
        options = {
          sans = lib.mkOption { type = lib.types.str; };
          mono = lib.mkOption { type = lib.types.str; };
          icon = lib.mkOption { type = lib.types.str; };
          size = lib.mkOption { type = lib.types.int; };
        };
      };
    };
  };

  config.settings =
    let
      inherit (config.font) sans mono;
      clockSegment = font: size: text: {
        interval = 60;
        format = "<span font_family='${font}' size='${size}pt'>{0:${text}}</span>";
        tooltip-format = "<span font_family='${mono}' size='large'>{calendar}</span>";
        calendar.format.months = "<span color='${config.scheme.base09}'><b>{}</b></span>";
        calendar.format.today = "<span color='${config.scheme.base09}'><b>{}</b></span>";
      };
    in
    {
      layer = "top";
      position = "right";
      width = 56;
      margin-top = 16;
      margin-bottom = 16;
      margin-left = 8;
      margin-right = 8;
      spacing = 16;
      modules-left = [
        "niri/workspaces"
      ];
      modules-center = [ "group/date-time" ];
      modules-right = [
        "tray"
        "custom/notification"
      ];
      "niri/workspaces" = {
        format = "{icon}";
        format-icons = {
          active = "●";
          default = "○";
        };
      };
      "group/date-time" = {
        orientation = "inherit";
        modules = [
          "clock#hour"
          "clock#minute"
          "clock#period"
          "clock#weekday"
          "clock#month"
          "clock#day"
        ];
      };
      "clock#hour" = clockSegment mono "15" "%I";
      "clock#minute" = clockSegment mono "15" "%M";
      "clock#period" = clockSegment mono "12" "%p";
      "clock#weekday" = clockSegment sans "12" "%a";
      "clock#month" = clockSegment sans "12" "%b";
      "clock#day" = clockSegment mono "15" "%d";
      tray = {
        icon-size = 20;
        spacing = 8;
      };
      "custom/notification" =
        let
          swaync-client = lib.getExe' pkgs.swaynotificationcenter "swaync-client";
        in
        {
          exec = "${swaync-client} -swb";
          exec-if = "which ${swaync-client}";
          restart-interval = 5;
          return-type = "json";
          format = "{icon}";
          format-icons = {
            notification = "notifications";
            none = "notifications_none";
            dnd-notification = "notifications_off";
            dnd-none = "notifications_off";
            inhibited-notification = "notifications_off";
            inhibited-none = "notifications_off";
            dnd-inhibited-notification = "notifications_off";
            dnd-inhibited-none = "notifications_off";
          };
          on-click = "${lib.getExe' pkgs.swaynotificationcenter "swaync-client"} -t -sw";
          on-click-right = "rofi-notifications";
        };
    };
  config."style.css".path = pkgs.replaceVars ./style.css {
    inherit (config.scheme)
      base00
      base02
      base03
      base04
      base05
      base06
      base07
      base09
      ;
    inherit (config.font) icon sans;
    fontSize = config.font.size;
  };
}
