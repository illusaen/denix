{
  lib,
  config,
  ...
}: let
  monitorConnectors =
    lib.pipe
    {
      num = lib.range 1 2;
      conn = [
        "DP"
        "HDMI-A"
      ];
    }
    [
      lib.cartesianProduct
      (map (x: "${x.conn}-${toString x.num}"))
    ];
  monitorOption = lib.mkOption {
    type = lib.types.submodule {
      options = {
        desc = lib.mkOption {type = lib.types.str;};
        connector = lib.mkOption {
          type = lib.types.enum monitorConnectors;
        };
      };
    };
  };
in {
  options.fleet.my.monitors = lib.mkOption {
    type = lib.types.submodule {
      options = {
        main = monitorOption;
        secondary = monitorOption;
        connectors = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          readOnly = true;
          default = {
            main = config.fleet.my.monitors.main.connector;
            secondary = config.fleet.my.monitors.secondary.connector;
          };
        };
        descriptions = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          readOnly = true;
          default = {
            main = config.fleet.my.monitors.main.desc;
            secondary = config.fleet.my.monitors.secondary.desc;
          };
        };
      };
    };
  };

  config.fleet.my.monitors = {
    main = {
      desc = "LG Electronics LG ULTRAGEAR+ 508RMWVJR505";
      connector = "DP-2";
    };
    secondary = {
      desc = "BOE Display 000000001";
      connector = "HDMI-A-2";
    };
  };

  config.den.aspects.display-manager.monitor = {
    nixos.hardware.i2c.enable = true;
  };
}
