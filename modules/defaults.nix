{ lib, den, ... }:
let
  cartesianProduct =
    platforms: users:
    builtins.concatLists (map (platform: map (user: { inherit platform user; }) users) platforms);

  maidClass =
    { host }:
    { aspect-chain, ... }:
    den._.forward {
      each = lib.attrNames host.users;
      fromClass = _: "md";
      intoClass = _: host.class;
      intoPath = userName: [
        "users"
        "users"
        userName
        "maid"
      ];
      fromAspect = _: lib.head aspect-chain;
    };

  mdPlatforms =
    { host }:
    { aspect-chain, ... }:
    den._.forward {
      each = cartesianProduct [
        "Linux"
        "Darwin"
      ] (lib.attrNames host.users);
      fromClass = cart: "md${cart.platform}";
      intoClass = _: host.class;
      intoPath = cart: [
        "users"
        "users"
        cart.user
        "maid"
      ];
      fromAspect = _: lib.head aspect-chain;
      guard = { pkgs, ... }: cart: lib.mkIf pkgs.stdenv."is${cart.platform}";
    };
in
{
  den.default = {
    nixos.system.stateVersion = "26.05";
    darwin.system.stateVersion = 6;

    includes = [
      den.provides.inputs'
      den.provides.self'
    ];
  };

  den.schema.user.classes = lib.mkDefault [ "maid" ];

  den.schema.host.maid.enable = true;

  den.ctx.user.includes = [
    den.provides.define-user
    (den.provides.user-shell "fish")
  ];

  den.ctx.host.includes = [
    den.provides.hostname
    den.provides.mutual-provider
    maidClass
    mdPlatforms
  ];
}
