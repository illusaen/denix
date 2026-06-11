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

  config.settings = {
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
    modules-center = [ "clock" ];
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
    clock = {
      interval = 60;
      format = "{0:%I\n%M\n%p\n\n%a\n%b\n%d}";
      tooltip-format = "<big>{calendar}</big>";
    };
    tray = {
      icon-size = 18;
      spacing = 8;
    };
    "custom/notification" = {
      exec = "swaync-client -swb";
      return-type = "json";
      format = "{icon}";
      format-icons = {
        notification = "󰂚";
        none = "󰂜";
        dnd-notification = "󰂛";
        dnd-none = "󰪑";
        inhibited-notification = "󰂛";
        inhibited-none = "󰪑";
        dnd-inhibited-notification = "󰂛";
        dnd-inhibited-none = "󰪑";
      };
      on-click = "swaync-client -t -sw";
      on-click-right = "rofi-notifications";
    };
  };
  config."style.css".path = pkgs.replaceVars ./style.css {
    inherit (config.scheme)
      base00
      base03
      base04
      base05
      base06
      base07
      base09
      ;
    inherit (config.font) mono icon sans;
    fontSize = config.font.size;
  };
}
