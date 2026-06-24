{
  symlinkJoin,
  writeShellApplication,
  local,
  systemd,
}:
symlinkJoin {
  name = "rofi-scripts";
  paths = [
    (writeShellApplication {
      name = "rofi-calculator";
      runtimeInputs = [local.rofi];
      text = "ROFI_LAYOUT_LIST=true rofi -show calc -modi calc -no-show-match -no-sort";
    })
    (writeShellApplication {
      name = "rofi-launcher";
      runtimeInputs = [local.rofi];
      text = ''ROFI_LAYOUT_GRID=true rofi -show drun -display-drun "Applications"'';
    })
    (writeShellApplication {
      name = "rofi-power-menu";
      runtimeInputs = [
        local.rofi
        local.niri
        local.swaylock
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
}
