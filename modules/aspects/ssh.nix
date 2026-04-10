{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.ssh ];
  den.aspects.ssh.nixos = {
    services.openssh.enable = true;
  };
}
