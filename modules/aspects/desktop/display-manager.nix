{ den, ... }:
{
  den.aspects.desktop._.display-manager = den.lib.perHost {
    nixos =
      { config, ... }:
      {
        services.displayManager = {
          enable = true;
          dms-greeter = {
            enable = true;
            compositor.name = "hyprland";
            quickshell.package = config.programs.dank-material-shell.quickshell.package;
          };
        };

        environment.etc."greetd/config.toml".text = ''
          [default_session]
          user = "wendy"
        '';
      };
  };
}
