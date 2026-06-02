{
  den.aspects.programs.switch-input = {
    nixos =
      {
        self',
        ...
      }:
      {
        environment.systemPackages = [ self'.packages.switch-input ];
        hardware.i2c.enable = true;
      };
  };
}
