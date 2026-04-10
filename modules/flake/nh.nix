# Exposes flake apps under the name of each host / home for building with nh.
{ den, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = den.lib.nh.denPackages { fromFlake = true; } pkgs;
    };

  den.ctx.host.includes = [ den.aspects.nh ];

  den.aspects.nh = {
    os =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ nh ];
      };

    hm = {
      programs.fish.shellAbbrs = {
        nd = "nh clean all";
        buildmodi = "nixos-rebuild switch --flake .#modi --target-host wendy@192.168.1.104 --use-remote-sudo";
      };
    };

    hmLinux.programs.fish.shellAbbrs.bb = "nh os switch .";
    hmDarwin.programs.fish.shellAbbrs.bb = "nh darwin switch .";
  };
}
