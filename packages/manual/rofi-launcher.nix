{
  writeShellApplication,
  rofi,
}:
writeShellApplication {
  name = "rofi-launcher";
  runtimeInputs = [ rofi ];
  text = ''rofi -show drun -display-drun "Applications"'';
}
