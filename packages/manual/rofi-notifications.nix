{
  writeShellApplication,
  rofi,
  swaynotificationcenter,
}:
writeShellApplication {
  name = "rofi-notifications";
  runtimeInputs = [
    rofi
    swaynotificationcenter
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
}
