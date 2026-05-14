{ den, ... }:
{
  den.aspects.wm.includes = with den.aspects.wm; [ gui ];

  den.aspects.wm.gui.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        qalculate-gtk
      ];
    };
}
