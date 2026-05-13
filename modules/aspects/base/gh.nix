{
  den.aspects.base.gh = {
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
