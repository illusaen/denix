{ den, ... }: {
  den.policies.env-to-os =
    { host, ... }:
    (den.lib.policy.route {
      fromClass = "env";
      intoClass = host.class;
      path = [
        "environment"
        (if host.class == "nixos" then "sessionVariables" else "variables")
      ];
      guard =
        _:
        builtins.elem host.class [
          "nixos"
          "darwin"
        ];
    });

  den.schema.host.includes = [ den.policies.env-to-os ];
  den.classes.env.description = "Environment variables class";
}
