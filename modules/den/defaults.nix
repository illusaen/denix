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
    nixos.system.stateVersion = "26.05";
    darwin.system.stateVersion = 6;
  };

  den.schema.user.classes = lib.mkDefault [ "hjem" ];
  den.schema.host = {
    options.ip = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    config.hjem.enable = true;
  };

  den.schema.user.includes = [
    den.provides.define-user
    den.provides.mutual-provider
    (den.provides.user-shell "fish")
  ];

  den.schema.host.includes = [
    den.provides.hostname
    hjemHostClass
  ];
}
