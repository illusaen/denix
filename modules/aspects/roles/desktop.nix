{ den, ... }:
{
  den.aspects.roles.desktop = {
    colmena = [ "desktop" ];
    includes = [
      den.aspects.base
      den.aspects.desktop
      den.aspects.theming
    ];
  };
}
