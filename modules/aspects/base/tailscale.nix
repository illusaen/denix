{ den, ... }:
{
  den.aspects.base.tailscale = {
    includes = [
      (den.lib.policy.when (
        {
          host ? null,
          ...
        }:
        host != null && host.hasAspect den.aspects.roles.desktop
      ) den.aspects.base.tailscale-systray)
    ];

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

    persist.directories = [ "/var/lib/tailscale" ];
  };

  den.aspects.base.tailscale-systray.nixos =
    { lib, config, ... }:
    {
      systemd.user.services.tailscale-systray = {
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        requires = [ "graphical-session-pre.target" ];
        after = [
          "graphical-session.target"
          "graphical-session-pre.target"
        ];
        description = "Official Tailscale systray application for Linux";
        script = "${lib.getExe config.services.tailscale.package} systray";
      };
    };
}
