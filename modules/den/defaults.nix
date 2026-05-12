{
  lib,
  den,
  helpers,
  ...
}:
let
  hjemHostClass =
    { host }:
    { aspect-chain, ... }:
    den._.forward {
      each =
        helpers.cartesian
          {
            left = "class";
            right = "username";
          }
          [
            "nixos"
            "darwin"
          ]
          (lib.attrNames host.users);
      fromClass = _: "hj";
      intoClass = item: item.class;
      intoPath = item: [
        "hjem"
        "users"
        item.username
      ];
      fromAspect = _: lib.head aspect-chain;
    };
in
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
    hjemHostClass
    den.batteries.hostname
  ];

  flake.den = den;
}
