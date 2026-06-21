{
  den.aspects.display-manager.regreet = {
    nixos = {
      lib,
      pkgs,
      fleet,
      environment,
      ...
    }: {
      # Enable the ReGreet module
      programs.regreet = let
        inherit (fleet.my) fonts theming;
      in {
        enable = true;
        theme = {
          package = pkgs.local.${theming.gtkTheme.packageName};
          name = theming.gtkTheme.name;
        };
        iconTheme = {
          package = pkgs.${theming.iconTheme.packageName};
          name = theming.iconTheme.name;
        };
        cursorTheme = {
          package = pkgs.${theming.cursorTheme.packageName};
          name = theming.cursorTheme.name;
        };
        font = {
          package = pkgs.inter;
          name = fonts.sans;
          size = 16;
        };
        settings = {
          GTK = {
            application_prefer_dark_theme = true;
          };
          "widget.clock" = {
            format = "%a %H:%M";
            resolution = "500ms";
            inherit (environment) timezone;
            label_width = 150;
          };
        };
      };
      security.pam.services = {
        greetd.enableGnomeKeyring = true;
        login.enableGnomeKeyring = true;
        swaylock.text = "auth include login";
      };

      services.displayManager.enable = true;

      services.greetd = let
        mainMonitor = fleet.my.monitors.main.desc;
        # Reuse the desktop Niri config, then add the greeter process.
        niri-config = pkgs.writeText "niri-config" ''
          include "${pkgs.local.niri}/niri-config.kdl"

          // Mitigate potential GTK portal slowdowns during login
          environment {
            GTK_USE_PORTAL "0"
            GDK_DEBUG "no-portals"
          }

          // Start ReGreet and immediately kill Niri upon successful login
          spawn-at-startup "sh" "-c" "${pkgs.niri}/bin/niri msg action focus-monitor ${lib.escapeShellArg mainMonitor}; ${pkgs.regreet}/bin/regreet; pkill -f niri"
        '';
      in {
        enable = true;
        settings = {
          default_session = {
            # Launch Niri using the minimal config for the login screen
            command = "${pkgs.niri}/bin/niri -c ${niri-config}";
            user = "greeter";
          };
        };
      };
    };
  };
}
