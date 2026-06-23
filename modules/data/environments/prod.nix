# Prod environment entity definition.
{
  den.environments.prod = {
    id = 1;
    domain = "lan";
    system-access-groups = ["system-access"];

    services = {
      homepage.domain = "homepage.json64.dev";
      jellyfin.domain = "jellyfin.json64.dev";
      kanidm.domain = "idm.json64.dev";
      open-webui.domain = "open-webui.json64.dev";
    };

    networks = {
      default = {
        cidr = "192.168.1.0/24";
        ipv6_cidr = "fe80::/64";
        description = "Default network for infrastructure hosts";
        gatewayIp = "192.168.1.1";
        gatewayIpV6 = "fe80::962a:6fff:fef2:cf4d";
        dnsServers = [
          "1.1.1.1"
          "8.8.8.8"
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
      environment = "prod";
      owner = "wendy";
    };

    monitoring = {
      scanEnvironments = [
        "prod"
        "dev"
      ];
    };
  };
}
