{ den, ... }:
{
  den.aspects.base.cli.includes = with den.aspects.base.cli; [ gh ];

  den.aspects.base.cli.gh = {
    provides.to-users.persistUser.files = [
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
