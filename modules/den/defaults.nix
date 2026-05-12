{
  lib,
  den,
  ...
}:
{
  den.default = {
    includes = [
      den.batteries.inputs'
      den.batteries.self'
    ];

    nixos.system.stateVersion = "26.05";
    darwin.system.stateVersion = 6;
  };

  den.schema.user = {
    includes = [
      den.batteries.define-user
      (den.batteries.user-shell "fish")
    ];
    classes = lib.mkDefault [ "hjem" ];
  };

  den.schema.host = {
    options.ip = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  den.schema.host.includes = [
    den.batteries.hostname
  ];

  flake.den = den;
}
