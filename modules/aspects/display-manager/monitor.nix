{
  den.aspects.display-manager.monitor = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        ddcutil
      ];
      hardware.i2c.enable = true;
    };
  };
}
