{ den, ... }:
{
  den.aspects.base.includes = with den.aspects.base; [
    cli
    firewall-collector
    fonts
    lix
    networking
    nix-config
    tailscale
    terminal
  ];
}
