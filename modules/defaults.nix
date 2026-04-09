{ lib, den, ... }:
{
  den.default = {
    nixos.system.stateVersion = "26.05";
    homeManager.home.stateVersion = "26.05";
    darwin.system.stateVersion = 6;

    includes = [
      den.provides.define-user
      den.provides.mutual-provider
      den.provides.inputs'
      den.provides.self'
    ];
  };

  # enable hm by default
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # host<->user provides
  den.ctx.user.includes = [
    (den.provides.user-shell "fish")
  ];

  den.ctx.host.includes = [
    den.provides.hostname
  ];
}
