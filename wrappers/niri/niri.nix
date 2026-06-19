{
  wlib,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  binds = import ./binds.nix;
  extraConfig = import ./extra.nix { inherit (config) cursor highlightColor; };
  inherit (import ./rules.nix) window-rules layer-rules;
in
{
  imports = [ wlib.wrapperModules.niri ];

  options = {
    highlightColor = mkOption {
      type = types.str;
      description = "highlight color used in overview";
    };
    cursor = mkOption {
      type = types.submodule {
        options = {
          name = mkOption { type = types.str; };
          size = mkOption { type = types.int; };
        };
      };
    };
    monitor = mkOption {
      type = types.submodule {
        options = {
          main = mkOption { type = types.str; };
          secondary = mkOption { type = types.str; };
        };
      };
    };
  };

  config.env = {
    GDK_BACKEND = "wayland,x11,*";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XDG_SESSION_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
  };
  config.settings = {
    inherit
      binds
      window-rules
      layer-rules
      ;
    layout = {
      gaps = 14;
      struts = {
        left = 0;
        right = 0;
        top = 8;
        bottom = 0;
      };
      background-color = "transparent";
      focus-ring.off = _: { };
      border.off = _: { };
      shadow = {
        on = _: { };
        softness = 28;
        spread = 4;
        offset = _: {
          props = {
            x = 0;
            y = 8;
          };
        };
        color = "#00000066";
      };
      center-focused-column = "on-overflow";
      default-column-width.proportion = 0.333;
      preset-column-widths = [
        { proportion = 0.333; }
        { proportion = 0.667; }
      ];
    };
    outputs = {
      "${config.monitor.main}" = {
        scale = 1;
        focus-at-startup = _: { };
        transform = "normal";
        position = _: {
          props = {
            x = 0;
            y = 0;
          };
        };
        mode = "5120x2160@100.035";
      };
      "${config.monitor.secondary}" = {
        scale = 1;
        transform = "90";
        position = _: {
          props = {
            x = 1080;
            y = 120;
          };
        };
      };
    };
    workspaces = {
      "music" = {
        open-on-output = config.monitor.secondary;
        layout = {
          default-column-width.proportion = 0.8;
          preset-column-widths = [
            { proportion = 0.8; }
            { proportion = 0.666667; }
          ];
        };
      };
      "chat" = {
        open-on-output = config.monitor.main;
      };
      "code" = {
        open-on-output = config.monitor.main;
      };
      "gaming" = {
        open-on-output = config.monitor.main;
        layout.always-center-single-column = _: { };
      };
      "__ndrop_foot" = {
        open-on-output = config.monitor.main;
      };
      "__ndrop_obsidian" = {
        open-on-output = config.monitor.main;
      };
    };
  }
  // extraConfig;
}
