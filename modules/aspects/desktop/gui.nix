{ den, ... }:
{
  den.aspects.desktop._.gui = den.lib.perHost {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          qalculate-gtk
          usbimager
        ];
      };
  };
}
