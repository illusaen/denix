{
  lib,
  den,
  ...
}:
let
  variablesClass =
    { aspect-chain, ... }:
    den._.forward {
      each = [
        "nixos"
        "darwin"
      ];
      fromClass = _: "vars";
      intoClass = lib.id;
      intoPath = item: [
        "environment"
        (if (item == "darwin") then "variables" else "sessionVariables")
      ];
      fromAspect = _: lib.head aspect-chain;
      evalConfig = true;
    };
in
{
  den.default = {
    nixos.system.stateVersion = "26.05";
    darwin.system.stateVersion = 6;
  };

  den.schema.user.classes = lib.mkDefault [ "hjem" ];
  den.schema.host.hjem.enable = true;

  den.ctx.user.includes = [
    den.provides.define-user
    (den.provides.user-shell "fish")
  ];

  den.ctx.host.includes = [
    den.provides.hostname
    den.provides.mutual-provider
    variablesClass
  ];
}
