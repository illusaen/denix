{
  den.aspects.base.gh = {
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
