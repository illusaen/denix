{ writeShellApplication, nix-output-monitor }:
writeShellApplication {
  name = "nb";
  runtimeInputs = [ nix-output-monitor ];
  text = builtins.readFile ./build.sh;
}
