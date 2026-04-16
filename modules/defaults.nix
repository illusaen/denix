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

  hmPlatforms =
    { host }:
    { aspect-chain, ... }:
    den._.forward {
      each = cartesianProduct [
        "Linux"
        "Darwin"
      ] (lib.attrNames host.users);
      fromClass = cart: "hm${cart.platform}";
      intoClass = _: host.class;
      intoPath = cart: [
        "home-manager"
        "users"
        cart.user
      ];
      fromAspect = _: lib.head aspect-chain;
      guard = { pkgs, ... }: cart: lib.mkIf pkgs.stdenv."is${cart.platform}";
      adaptArgs =
        { config, ... }:
        {
          osConfig = config;
        };
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
  den.schema.user.classes = lib.mkDefault [
    "homeManager"
    "maid"
  ];

  den.schema.host.maid.enable = true;

  # host<->user provides
  den.ctx.user.includes = [
    den.provides.define-user
    (den.provides.user-shell "fish")
  ];

  den.ctx.host.includes = [
    den.provides.hostname
    den.provides.mutual-provider
    hmClass
    hmPlatforms
    maidClass
    mdPlatforms
  ];
}
