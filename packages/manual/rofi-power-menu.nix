{
  writeShellApplication,
  rofi,
  niri,
  swaylock,
  systemd,
  rootPath ? null,
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
      printf '%s\0icon\x1f%s\n' \
        "Lock" "system-lock-screen" \
        "Suspend" "system-suspend" \
        "Log Out" "system-log-out" \
        "Restart" "system-reboot" \
        "Shut Down" "system-shutdown" |
        rofi -dmenu -p 'Power' -i -show-icons
    )"

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
}
