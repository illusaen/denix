{
  writeShellApplication,
  rofi,
}:
writeShellApplication {
  name = "rofi-calculator";
  runtimeInputs = [ rofi ];
  text = "ROFI_LAYOUT_LIST=true rofi -show calc -modi calc -no-show-match -no-sort";
}
