{
  den,
  lib,
  ...
}: {
  den.classes.hjemLinux.description = "hjem modules for Linux hosts";
  den.classes.hjemDarwin.description = "hjem modules for Darwin hosts";

  den.policies.hjemLinux-to-hjem = {host, ...}:
    lib.optional (lib.hasSuffix "-linux" host.system) (
      den.lib.policy.route {
        fromClass = "hjemLinux";
        intoClass = "hjem";
        path = [];
      }
    );

  den.policies.hjemDarwin-to-hjem = {host, ...}:
    lib.optional (lib.hasSuffix "-darwin" host.system) (
      den.lib.policy.route {
        fromClass = "hjemDarwin";
        intoClass = "hjem";
        path = [];
      }
    );

  # Route policies fire at user scope where host.system is available
  den.schema.user.includes = [
    den.policies.hjemLinux-to-hjem
    den.policies.hjemDarwin-to-hjem
  ];
}
