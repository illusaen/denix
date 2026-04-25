# Provides shell utilities under `den.sh` for building OS configurations using
# github:nix-community/nh instead of nixos-rebuild, etc
{
  den,
  ...
}:
{
  den.ctx.host.includes = [ den.aspects.nh ];
  den.aspects.nh = den.lib.perHost (
    { host }:
    {
      os = {
        programs.fish.shellAbbrs = {
          nd = "nh clean all";
          buildmodi = "nixos-rebuild switch --flake .#modi --target-host wendy@192.168.1.104 --use-remote-sudo";
          bb = "${host.name} switch";
        };
      };
    }
  );
}
