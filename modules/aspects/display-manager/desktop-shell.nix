{ rootPath, ... }:
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
      let
        rofi = pkgs.rofi.override { plugins = [ pkgs.rofi-calc ]; };
        launcher = pkgs.writeShellApplication {
          name = "cosmic-launcher";
          runtimeInputs = [ rofi ];
          text = ''rofi -show drun -display-drun "Applications"'';
        };
        calculator = pkgs.writeShellApplication {
          name = "cosmic-calculator";
          runtimeInputs = [ rofi ];
          text = "rofi -show calc -modi calc -no-show-match -no-sort";
        };
        powerMenu = pkgs.writeShellApplication {
          name = "cosmic-power-menu";
          runtimeInputs = [
            rofi
            pkgs.niri
            pkgs.swaylock
            pkgs.systemd
          ];
          text = ''
            choice="$(printf 'Lock\nSuspend\nLog Out\nRestart\nShut Down' | rofi -dmenu -p 'Power' -i)"
            case "$choice" in
              Lock)
                swaylock --daemonize \
                  --image ${rootPath + /resources/cosmic-tree.png} \
                  --scaling fill \
                  --indicator-radius 90 \
                  --indicator-thickness 8 \
                  --inside-color 141c25dd \
                  --ring-color ecaf8d \
                  --key-hl-color a8b986 \
                  --line-color 00000000 \
                  --separator-color 00000000
                ;;
              Suspend) systemctl suspend ;;
              "Log Out") niri msg action quit ;;
              Restart) systemctl reboot ;;
              "Shut Down") systemctl poweroff ;;
            esac
          '';
        };
        notifications = pkgs.writeShellApplication {
          name = "cosmic-notifications";
          runtimeInputs = [
            rofi
            pkgs.swaynotificationcenter
          ];
          text = ''
            choice="$(printf 'Open Notification Center\nToggle Do Not Disturb\nClear Notifications' | rofi -dmenu -p 'Notifications' -i)"
            case "$choice" in
              "Open Notification Center") swaync-client -t -sw ;;
              "Toggle Do Not Disturb") swaync-client -d -sw ;;
              "Clear Notifications") swaync-client -C ;;
            esac
          '';
        };
      in
      {
        environment.systemPackages = [
          rofi
          launcher
          calculator
          powerMenu
          notifications
          pkgs.swaynotificationcenter
        ];

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
          "rofi/config.rasi".text = ''
            configuration {
              modi: "drun,run,window";
              show-icons: true;
              display-drun: "Applications";
              drun-display-format: "{name}";
              font: "${fonts.sans} 13";
              icon-theme: "${fleet.my.theming.iconTheme.name}";
            }
            * {
              bg: ${colors.base00}e6;
              surface: ${colors.base01}f2;
              selected: ${colors.base02};
              text: ${colors.base05};
              muted: ${colors.base04};
              accent: ${colors.base09};
            }
            window {
              width: 620px;
              border: 1px;
              border-color: ${colors.base03};
              border-radius: 20px;
              background-color: @bg;
              padding: 18px;
            }
            mainbox { spacing: 14px; background-color: transparent; }
            inputbar {
              padding: 13px 16px;
              border-radius: 13px;
              background-color: @surface;
              children: [ prompt, entry ];
            }
            prompt { text-color: @accent; margin: 0 12px 0 0; }
            entry { text-color: @text; placeholder: "Search"; placeholder-color: @muted; }
            listview { lines: 7; columns: 1; spacing: 6px; background-color: transparent; }
            element { padding: 11px 13px; border-radius: 11px; background-color: transparent; }
            element selected { background-color: @selected; }
            element-icon { size: 25px; margin: 0 12px 0 0; }
            element-text { text-color: @text; vertical-align: 0.5; }
          '';

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
