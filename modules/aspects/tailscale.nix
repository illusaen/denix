{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.tailscale ];
  den.aspects.tailscale = {
    nixos =
      { config, ... }:
      {
        services.tailscale.enable = true;
        # 2. Force tailscaled to use nftables (Critical for clean nftables-only systems)
        # This avoids the "iptables-compat" translation layer issues.
        systemd.services.tailscaled.serviceConfig.Environment = [
          "TS_DEBUG_FIREWALL_MODE=nftables"
        ];

        networking.nftables.enable = true;
        networking.firewall = {
          enable = true;
          # Always allow traffic from your Tailscale network
          trustedInterfaces = [ "tailscale0" ];
          # Allow the Tailscale UDP port through the firewall
          allowedUDPPorts = [ config.services.tailscale.port ];
        };
      };
    darwin.homebrew.masApps."Tailscale" = 1475387142;
  };
}
