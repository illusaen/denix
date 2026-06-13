{
  writeShellApplication,
  rofi,
}:
writeShellApplication {
  name = "rofi-launcher";
  runtimeInputs = [ rofi ];
  text = ''ROFI_LAYOUT_GRID=true rofi -show drun -display-drun "Applications"'';
}
