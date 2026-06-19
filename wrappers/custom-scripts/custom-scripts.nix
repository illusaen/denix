{
  config,
  wlib,
  pkgs,
  lib,
  ...
}:
let
  opnixConfig = lib.escapeShellArg (
    builtins.toJSON {
      vars = [
        {
          name = "GH_TOKEN";
          reference = "op://Service/Github/token";
        }
      ];
    }
  );

  pythonScript =
    name: script: runtimeInputs:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = ''
        exec python3 ${script} "$@"
      '';
    };
in
{
  imports = [ wlib.modules.symlinkScript ];

  options.opnixPackage = lib.mkOption { type = lib.types.package; };

  config.package = pkgs.symlinkJoin {
    name = "custom-scripts";
    paths = [
      (pythonScript "dconf2nix" ./scripts/dconf-to-nix.py [ pkgs.python3 ])
      (pythonScript "monitor-brightness" ./scripts/monitor-brightness.py [
        pkgs.ddcutil
        pkgs.python3
      ])
      (pythonScript "ndrop" ./scripts/ndrop.py [
        pkgs.local.niri
        pkgs.python3
      ])
      (pythonScript "niri-workspace" ./scripts/niri-workspace.py [
        pkgs.local.niri
        pkgs.python3
      ])
      (pythonScript "switcher" ./scripts/switch-input.py [
        pkgs.ddcutil
        pkgs.i2c-tools
        pkgs.python3
      ])
      (pkgs.writeShellApplication {
        name = "nb";
        runtimeInputs = [ pkgs.nix-output-monitor ];
        text = builtins.readFile ./scripts/nix-build.sh;
      })
      (pkgs.writeShellApplication {
        name = "ndrop-obsidian";
        text = ''
          exec ${pkgs.electron_40}/bin/electron \
            --class=ndrop-obsidian \
            ''${NIXOS_OZONE_WL:+''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-wayland-ime=true --wayland-text-input-version=3}} \
            ${pkgs.obsidian}/share/obsidian/app.asar \
            "$@"
        '';
      })
      (pkgs.writeShellScriptBin "load-opnix" ''
        if [ -f .env ]; then
          exit 0
        fi
        echo "Loading GITHUB_TOKEN with opnix."
        if output="$(${config.opnixPackage}/bin/opnix env -config-json ${opnixConfig} -format shell)"; then
          echo "$output" > .env
        else
          echo "WARNING: failed to resolve opnix environment variables" >&2
        fi
      '')
      (pkgs.writeShellApplication {
        name = "ff";
        runtimeInputs = with pkgs; [
          fd
          jq
        ];
        text = ''
          exec bash ${
            pkgs.replaceVars ./scripts/find-ephemeral-persist.sh {
              ignored = builtins.readFile ./scripts/ignored.json;
            }
          } "$@"
        '';
      })
      (pkgs.writeShellApplication {
        name = "fo";
        runtimeInputs = with pkgs; [
          fd
          jq
        ];
        text = ''
          exec bash ${./scripts/find-orphaned-persist.sh} "$@"
        '';
      })
      (pkgs.writeShellApplication {
        name = "rofi-calculator";
        runtimeInputs = [ pkgs.local.rofi ];
        text = "ROFI_LAYOUT_LIST=true rofi -show calc -modi calc -no-show-match -no-sort";
      })
      (pkgs.writeShellApplication {
        name = "rofi-launcher";
        runtimeInputs = [ pkgs.local.rofi ];
        text = ''ROFI_LAYOUT_GRID=true rofi -show drun -display-drun "Applications"'';
      })
      (pkgs.writeShellApplication {
        name = "rofi-notifications";
        runtimeInputs = with pkgs.local; [
          rofi
          swaync
        ];
        text = ''
          choice="$(
            printf '%s\0display\x1f%s\n' \
              "Open" "" \
              "DND" "" \
              "Clear" "X" |
              ROFI_LAYOUT_ACTIONS=true rofi -dmenu -p 'Notifications' -i
          )"

          case "$choice" in
            "Open") swaync-client -t -sw ;;
            "DND") swaync-client -d -sw ;;
            "Clear") swaync-client -C ;;
          esac
        '';
      })
      (pkgs.writeShellApplication {
        name = "rofi-power-menu";
        runtimeInputs = with pkgs; [
          local.rofi
          niri
          swaylock
          systemd
        ];
        text = ''
          choice="$(
            printf '%s\0display\x1f%s\n' \
              "Lock" "" \
              "Log Out" "" \
              "Restart" "" \
              "Shut Down" "" |
              ROFI_LAYOUT_ACTIONS=true ROFI_ACTION_TEXT_PADDING='0 8px 0 0' rofi -dmenu -p 'Power' -i
          )"

          case "$choice" in
            Lock) swaylock ;;
            "Log Out") niri msg action quit ;;
            Restart) systemctl reboot ;;
            "Shut Down") systemctl poweroff ;;
          esac
        '';
      })
    ];
  };
}
