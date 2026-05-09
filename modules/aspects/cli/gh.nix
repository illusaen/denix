_: {
  den.aspects.cli._.gh = {
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
