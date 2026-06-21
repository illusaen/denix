{den, ...}: {
  den.aspects.roles.server = {
    colmena = ["server"];
    includes = [
      den.aspects.base
      den.aspects.server
    ];
  };
}
