{
  writeShellApplication,
  ddcutil,
  python3,
}:
writeShellApplication {
  name = "monitor-brightness";
  runtimeInputs = [
    ddcutil
    python3
  ];
  text = ''
    python3 ${./monitor-brightness.py} "$@"
  '';
}
