{ den, ... }:
{
  den.aspects.cli._.gh = den.lib.perHost {
    persistUser.files = [
      ".config/gh/config.yml"
      ".config/gh/hosts.yml"
    ];

    os =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ gh ];
      };
  };
}
