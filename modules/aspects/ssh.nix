{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.ssh ];
  den.aspects.ssh = den.lib.perHost {
    nixos = {
      services.openssh.enable = true;
    };
  };
}
