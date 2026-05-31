{
  writeShellApplication,
  ddcutil,
  i2c-tools,
  python3,
}:
writeShellApplication {
  name = "switcher";
  runtimeInputs = [
    ddcutil
    i2c-tools
    python3
  ];
  text = ''
    python3 ${./switch-input.py} "$@"
  '';
}
