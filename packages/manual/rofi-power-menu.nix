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
}
