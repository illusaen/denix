{ den, ... }:
{
  den.aspects.display-manager = {
    includes = with den.aspects.display-manager; [
      dms
      niri
      hide-desktop-entries
      paneru
    ];

    nixos =
      { config, ... }:
      {
        services.displayManager = {
          enable = true;
          dms-greeter = {
            enable = true;
            compositor.name = "niri";
            quickshell.package = config.programs.dank-material-shell.quickshell.package;
          };
        };

        environment.etc = {
          "greetd/config.toml".text = ''
            [default_session]
            command = "dms-greeter --command niri -C /etc/greetd/niri.kdl"
          '';
          "greetd/niri.kdl".text = ''
            hotkey-overlay {
                skip-at-startup
            }

            environment {
                DMS_RUN_GREETER "1"
            }

            gestures {
              hot-corners {
                off
              }
            }
          '';
        };
      };
  };
}
