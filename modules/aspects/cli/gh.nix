{ den, ... }:
{
  den.aspects.cli._.gh = den.lib.perHost {
    persistUser.directories = [
      ".config/gh"
    ];

    os =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ gh ];
      };
  };
}
