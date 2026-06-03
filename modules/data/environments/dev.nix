# Environment entity registry.
#
# Declares den.environments — the registry consumed by fleet policies
# and scope-engine for environment entity resolution.
_:
let
  DOMAIN = "wendy.dev";
in
{
  # Dev environment entity definition.
  den.environments.dev = {
    id = 2;
    domain = DOMAIN;
    system-access-groups = [ "system-access" ];

    networks = {
      default = {
        cidr = "10.9.0.0/16";
        ipv6_cidr = "fd64:1:1::/64";
        description = "Default network for infrastructure hosts";
        gatewayIp = "10.9.0.1";
        gatewayIpV6 = "fe80::962a:6fff:fef2:cf4d";
        dnsServers = [
          "1.1.1.1"
          "2606:4700:4700::1111"
          "1.0.0.1"
          "2606:4700:4700::1001"
          "2a01:4f8:c2c:123f::1"
          "2a00:1098:2b::1"
        ];
        wireless = {
          ssid = "Routed";
          pskRef = "ext:psk_arcade";
        };
      };
    };

    acme = {
      server = "https://acme-v02.api.letsencrypt.org/directory";
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
    };

    timezone = "America/Chicago";

    location = {
      country = "US";
      region = "us-central";
    };

    tags = {
      environment = "dev";
      owner = "wendy";
    };

    delegation = {
      metricsTo = "prod";
      authTo = "prod";
      logsTo = "prod";
    };
  };
}
