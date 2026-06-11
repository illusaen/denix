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
    choice="$(printf 'Open Notification Center\nToggle Do Not Disturb\nClear Notifications' | rofi -dmenu -p 'Notifications' -i)"
    case "$choice" in
      "Open Notification Center") swaync-client -t -sw ;;
      "Toggle Do Not Disturb") swaync-client -d -sw ;;
      "Clear Notifications") swaync-client -C ;;
    esac
  '';
}
