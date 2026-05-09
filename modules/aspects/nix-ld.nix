{ den, ... }:
{
  den.schema.host.includes = [ den.aspects.nix-ld ];
  den.aspects.nix-ld = {
    nixos.programs.nix-ld.enable = true;
  };
}
