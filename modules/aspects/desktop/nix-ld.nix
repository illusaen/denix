{ den, ... }:
{
  den.aspects.desktop._.nix-ld = den.lib.perHost {
    nixos.programs.nix-ld.enable = true;
  };
}
