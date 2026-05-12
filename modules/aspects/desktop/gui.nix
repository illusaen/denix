{
  den.aspects.desktop._.gui = {
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
