{ writeShellApplication, python3 }:
writeShellApplication {
  name = "dconf2nix";
  runtimeInputs = [
    python3
  ];
  text = ''
    python3 ${./dconf-to-nix.py} "$@"
  '';
}
