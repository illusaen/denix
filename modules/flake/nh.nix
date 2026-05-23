# Provides shell utilities under `den.sh` for building OS configurations using
# github:nix-community/nh instead of nixos-rebuild, etc
{
  den,
  ...
}:
{
  den.schema.host.includes = [ den.aspects.nh ];
  den.aspects.nh = {
    shell.shellAbbrs.nd = "nh clean all";
  };
}
