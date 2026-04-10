{ lib, den, ... }:
let
  hmClass =
    { host }:
    { aspect-chain, ... }:
    den._.forward {
      each = lib.attrNames host.users;
      fromClass = _: "hm";
      intoClass = _: host.class;
      intoPath = userName: [
        "home-manager"
        "users"
        userName
      ];
      fromAspect = _: lib.head aspect-chain;
    };
in
{
  den.default = {
    nixos.system.stateVersion = "26.05";
    homeManager.home.stateVersion = "26.05";
    darwin.system.stateVersion = 6;

    includes = [
      den.provides.inputs'
      den.provides.self'
    ];
  };

  # enable hm by default
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # host<->user provides
  den.ctx.user.includes = [
    den.provides.define-user
    (den.provides.user-shell "fish")
  ];

  den.ctx.host.includes = [
    den.provides.hostname
    den.provides.mutual-provider
    hmClass
  ];
}
