{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.nix-ld ];
  den.aspects.nix-ld = den.lib.perHost {
    nixos.programs.nix-ld.enable = true;
  };
}
