{den, ...}: {
  den.aspects.roles.desktop = {
    colmena = ["desktop"];
    includes = [
      den.aspects.base
      den.aspects.programs
      den.aspects.theming
      den.aspects.display-manager
    ];
  };
}
