{
  wlib,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  binds = import ./binds.nix;
  layout = import ./layout.nix {inherit (config) colors;};
  extraConfig = import ./extra.nix {
    inherit (config) cursor;
    highlightColor = config.colors.base0E;
  };
  inherit (import ./rules.nix) window-rules layer-rules;
in {
  imports = [wlib.wrapperModules.niri];

  options = {
    colors = mkOption {type = types.raw;};
    cursor = mkOption {
      type = types.submodule {
        options = {
          name = mkOption {type = types.str;};
          size = mkOption {type = types.int;};
        };
      };
    };
    monitors = mkOption {
      type = types.submodule {
        options = {
          main = mkOption {type = types.str;};
          secondary = mkOption {type = types.str;};
        };
      };
    };
  };

  config.env = {
    GDK_BACKEND = "wayland,x11,*";
    NIXOS_OZONE_WL = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XDG_SESSION_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
  };
  config.settings =
    {
      inherit
        binds
        window-rules
        layer-rules
        layout
        ;
      outputs = {
        "${config.monitors.main}" = {
          scale = 1;
          focus-at-startup = _: {};
          transform = "normal";
          position = _: {
            props = {
              x = 0;
              y = 0;
            };
          };
          mode = "5120x2160@100.035";
        };
        "${config.monitors.secondary}" = {
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
          open-on-output = config.monitors.secondary;
          layout = {
            default-column-width.proportion = 0.8;
            preset-column-widths = [
              {proportion = 0.8;}
              {proportion = 0.666667;}
            ];
          };
        };
        "chat" = {
          open-on-output = config.monitors.main;
        };
        "code" = {
          open-on-output = config.monitors.main;
        };
        "gaming" = {
          open-on-output = config.monitors.main;
          layout.always-center-single-column = _: {};
        };
        "__ndrop_foot" = {
          open-on-output = config.monitors.main;
        };
      };
    }
    // extraConfig;
}
