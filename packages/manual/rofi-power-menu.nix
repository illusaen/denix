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
      printf '%s\0icon\x1f<span color="white">%s</span>\n' \
        "Lock" "" \
        "Log Out" "" \
        "Restart" "" \
        "Shut Down" "" |
        ROFI_LAYOUT_ACTIONS=true rofi -dmenu -p 'Power' -i -show-icons
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
      "Log Out") niri msg action quit ;;
      Restart) systemctl reboot ;;
      "Shut Down") systemctl poweroff ;;
    esac
  '';
}
