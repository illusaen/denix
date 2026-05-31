{
  lib,
  den,
  inputs,
  ...
}:
{
  imports = [ inputs.den.flakeModule ];

  den.default = {
    includes = [
      den.batteries.inputs'
      den.batteries.self'
      den.batteries.define-user
      den.batteries.primary-user
      den.batteries.hostname
    ];

    nixos.system.stateVersion = "26.05";
    darwin.system.stateVersion = 6;
  };

  den.schema.host.includes = [ den.aspects.base ];

  den.schema.user.includes = [
    (den.batteries.user-shell "fish")
    (den.lib.policy.mkPolicy "user-aspect-auto-include" (
      { host, user, ... }:
      lib.optional (den.aspects ? ${host.name} && den.aspects.${host.name} ? ${user.name}) (
        den.lib.policy.include den.aspects.${host.name}.${user.name}
      )
    ))
  ];
}
