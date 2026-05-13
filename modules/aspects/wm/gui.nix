{
  den.aspects.wm.gui.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        qalculate-gtk
      ];
    };
}
