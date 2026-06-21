# Pipe collection policies for cross-host discovery.
#
# Declares collection policies for all quirks that need cross-host
# aggregation, wired into host schema so every host collects pipe
# entries from peers. For example, firewalls are specific to each
# host and so are not collected here.
{den, ...}: let
  inherit (den.lib.policy) pipe;
in {
  den.policies.collect-host-addrs = _: [
    (pipe.from "host-addrs" [
      (pipe.collectAll ({host, ...}: host != null))
    ])
  ];

  den.policies.collect-prometheus-targets = _: [
    (pipe.from "prometheus-targets" [
      (pipe.collect ({host, ...}: host != null))
    ])
  ];

  den.schema.host.includes = [
    den.policies.collect-host-addrs
    den.policies.collect-prometheus-targets
  ];
}
