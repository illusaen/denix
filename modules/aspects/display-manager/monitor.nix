{lib, ...}: let
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
  monitorOption = default:
    lib.mkOption {
      type = lib.types.submodule {
        options = {
          desc = lib.mkOption {type = lib.types.str;};
          connector = lib.mkOption {
            type = lib.types.enum monitorConnectors;
          };
        };
      };
      inherit default;
    };
in {
  config.den.aspects.display-manager.monitor = {
    settings = {
      main = monitorOption {
        desc = "LG Electronics LG ULTRAGEAR+ 508RMWVJR505";
        connector = "DP-2";
      };
      secondary = monitorOption {
        desc = "BOE Display 000000001";
        connector = "HDMI-A-2";
      };
    };

    nixos.hardware.i2c.enable = true;
  };
}
