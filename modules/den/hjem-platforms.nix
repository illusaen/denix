{ den, ... }:
{
  den.classes.hjemLinux.description = "Hjem modules for Linux hosts";
  den.classes.hjemDarwin.description = "Hjem modules for Darwin hosts";

  den.policies.hjemLinux-to-hjem =
    _:
    (den.lib.policy.route {
      fromClass = "hjemLinux";
      intoClass = "hjem";
      path = [ ];
      # guard = _: host.class == "linux";
    });

  den.policies.hjemDarwin-to-hjem =
    _:
    (den.lib.policy.route {
      fromClass = "hjemDarwin";
      intoClass = "hjem";
      path = [ ];
      # guard = _: host.class == "darwin";
    });

  den.schema.user.includes = [
    den.policies.hjemLinux-to-hjem
    den.policies.hjemDarwin-to-hjem
  ];
}
