# Exposes flake apps under the name of each host / home for building with nh.
{ den, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = den.lib.nh.denPackages { fromFlake = true; } pkgs;
    };

  den.ctx.host.includes = [
    (
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ nh ];
      }
    )
  ];
}
