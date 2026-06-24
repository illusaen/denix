{
  den.aspects.display-manager.regreet = {
    nixos = {
      lib,
      pkgs,
      host,
      environment,
      ...
    }: {
      programs.regreet = let
        fonts = host.settings.base.fonts;
        theming = host.settings.theming;
      in {
        enable = true;
        theme = {
          package =
            pkgs.local.${theming.gtkTheme.packageName} or pkgs.${theming.gtkTheme.packageName};
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
          size = fonts.sizes.applications;
        };
        settings = {
          skip_selection = true;
          background = {
            path = host.settings.programs.wallpaper.wallpaper;
            fit = "Fill";
          };
          GTK = {
            application_prefer_dark_theme = true;
          };
          "widget.clock" = {
            format = "%A %B %d%n%I:%M %p";
            inherit (environment) timezone;
          };
        };
        extraCss = let
          inherit (host.settings.base.base16.scheme.withHashtag) base05;
        in ''
          * {
            color: ${base05};
            font-weight: 500;
            background-color: transparent;
            border: none;
            box-shadow: none;
            border-radius: 8px;
          }

          grid > label:nth-child(1), label:nth-child(2), grid > label:nth-child(4), combobox box > arrow {
            opacity: 0;
            min-width: 0;
            min-height: 0;
            padding: 0;
            margin: 0;
          }

          picture {
            filter: blur(32px);
            opacity: 0.8;
          }

          window {
            background-color: alpha(${base05}, 0.1);
          }

          combobox, entry {
            border: 1px solid alpha(${base05}, 0.5);
          }

          entry > text {
            padding: 2px 8px;
          }

          combobox cellview {
            padding: 0 4px;
          }

          combobox:focus, entry:focus {
            border: 1px solid ${base05};
          }

          button {
            padding: 8px 12px;
          }

          button:hover, infobar {
            background-color: alpha(${base05}, 0.25);
          }
        '';
      };
      security.pam.services = {
        greetd.enableGnomeKeyring = true;
        login.enableGnomeKeyring = true;
        swaylock.text = "auth include login";
      };

      services.displayManager.enable = true;

      services.greetd = let
        mainMonitor = host.settings."display-manager".monitor.main.desc;
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
