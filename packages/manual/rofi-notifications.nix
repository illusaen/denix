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
      printf '%s\0icon\x1f<span color="white">%s</span>\n' \
        "Open" "" \
        "DND" "" \
        "Clear" "" |
        ROFI_LAYOUT_ACTIONS=true rofi -dmenu -p 'Notifications' -i -show-icons
    )"

    case "$choice" in
      "Open") swaync-client -t -sw ;;
      "DND") swaync-client -d -sw ;;
      "Clear") swaync-client -C ;;
    esac
  '';
}
