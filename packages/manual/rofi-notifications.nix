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
      printf '%s\0icon\x1f%s\n' \
        "Open" "notification-symbolic" \
        "DND" "notification-disabled-symbolic" \
        "Clear" "edit-clear-all-symbolic" |
        rofi -dmenu -p 'Notifications' -i -show-icons
    )"

    case "$choice" in
      "Open") swaync-client -t -sw ;;
      "DND") swaync-client -d -sw ;;
      "Clear") swaync-client -C ;;
    esac
  '';
}
