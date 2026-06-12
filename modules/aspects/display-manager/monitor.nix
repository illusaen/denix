{
  den.aspects.display-manager.monitor = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        ddcutil
        local.switch-input
        local.monitor-brightness
      ];
      hardware.i2c.enable = true;
    };
  };
}
