{
  den.aspects.display-manager.desktop-shell = {
    provides.to-users.persistUser.directories = [
      ".cache/swaync"
    ];

    nixos =
      {
        pkgs,
        lib,
        ...
      }:
      {
        environment.systemPackages =
          with pkgs;
          [
            swaynotificationcenter
          ]
          ++ (with pkgs.local; [
            rofi-launcher
            rofi-calculator
            rofi-power-menu
            rofi-notifications
          ]);

        systemd.user.services = {
          swaync = {
            description = "Notification center";
            wantedBy = [ "graphical-session.target" ];
            partOf = [ "graphical-session.target" ];
            after = [ "graphical-session-pre.target" ];
            serviceConfig = {
              ExecStart = lib.getExe pkgs.swaynotificationcenter;
              Restart = "on-failure";
            };
          };
        };
      };

    provides.to-users.hjemLinux =
      {
        fleet,
        ...
      }:
      let
        inherit (fleet.my) fonts;
        colors = fleet.my.base16.scheme.withHashtag;
      in
      {
        xdg.config.files = {
          "swaync/config.json".text = builtins.toJSON {
            positionX = "right";
            positionY = "top";
            layer = "overlay";
            control-center-margin-top = 56;
            control-center-margin-right = 12;
            control-center-width = 420;
            notification-window-width = 420;
            notification-icon-size = 48;
            notification-body-image-height = 100;
            notification-body-image-width = 180;
            timeout = 6;
            timeout-low = 3;
            timeout-critical = 0;
            fit-to-screen = false;
            control-center-exclusive-zone = false;
            widgets = [
              "title"
              "dnd"
              "notifications"
            ];
          };

          "swaync/style.css".text = ''
            * { font-family: "${fonts.sans}"; color: ${colors.base05}; }
            .control-center, .notification-row .notification-background {
              border: 1px solid ${colors.base03}80;
              border-radius: 20px;
              background: ${colors.base00}ed;
              box-shadow: 0 12px 36px rgba(0, 0, 0, 0.45);
            }
            .control-center { padding: 14px; }
            .notification-row { outline: none; margin: 6px; }
            .notification { padding: 12px; border-radius: 18px; }
            .notification-content { padding: 4px; }
            .summary { font-size: 14px; font-weight: 700; color: ${colors.base07}; }
            .body { color: ${colors.base04}; }
            .time { color: ${colors.base03}; }
            .close-button {
              border-radius: 999px;
              background: ${colors.base02};
              color: ${colors.base05};
            }
            .widget-title { margin: 4px 8px 12px; }
            .widget-title > label { font-size: 20px; font-weight: 700; color: ${colors.base07}; }
            .widget-title > button, .widget-dnd > switch {
              border: 1px solid ${colors.base03};
              border-radius: 999px;
              background: ${colors.base01};
            }
            .widget-dnd { margin: 8px; }
            .widget-dnd > switch:checked { background: ${colors.base09}; }
          '';
        };
      };
  };
}
