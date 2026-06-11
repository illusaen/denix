{
  writeShellApplication,
  rofi,
}:
writeShellApplication {
  name = "rofi-calculator";
  runtimeInputs = [ rofi ];
  text = "rofi -show calc -modi calc -no-show-match -no-sort";
}
