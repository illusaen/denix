# Provides shell utilities under `den.sh` for building OS configurations using
# github:nix-community/nh instead of nixos-rebuild, etc
{
  den,
  ...
}:
{
  den.schema.host.includes = [ den.aspects.nh ];
  den.aspects.nh =
    { host }:
    {
      shell.shellAbbrs = {
        nd = "nh clean all";
        buildmodi = "nixos-rebuild switch --flake .#modi --target-host wendy@192.168.1.104 --use-remote-sudo";
        bb = "${host.name} switch";
      };
    };
}
