{
  writeShellApplication,
  rofi,
  niri,
  swaylock,
  systemd,
}:
writeShellApplication {
  name = "rofi-power-menu";
  runtimeInputs = [
    rofi
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
}
