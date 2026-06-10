{
  den.aspects.display-manager.monitor = {
    nixos = { pkgs, self', ... }: {
      environment.systemPackages = with pkgs; [
        ddcutil
        self'.packages.switch-input
        self'.packages.monitor-brightness
      ];
      hardware.i2c.enable = true;
    };
  };
}
