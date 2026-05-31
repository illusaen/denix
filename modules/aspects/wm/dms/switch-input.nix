{ den, ... }:
{
  den.aspects.wm.includes = with den.aspects.wm; [ switch-input ];

  den.aspects.wm.switch-input = {
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
