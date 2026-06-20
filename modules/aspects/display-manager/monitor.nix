{ lib, ... }: {
  options.fleet.my.monitors = lib.mkOption {
    type = lib.types.submodule {
      options = {
        main = lib.mkOption { type = lib.types.str; };
        secondary = lib.mkOption { type = lib.types.str; };
      };
    };

  };

  config.fleet.my.monitors = {
    main = "DP-2";
    secondary = "HDMI-A-2";
  };

  config.den.aspects.display-manager.monitor = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        ddcutil
      ];
      hardware.i2c.enable = true;
    };
  };
}
