{ den, ... }:
{
  den.aspects.base.includes = with den.aspects.base; [
    audio
    cli
    darwin-config
    firewall-collector
    fonts
    lix
    networking
    nix-config
    tailscale
    terminal
    xdg
  ];
}
