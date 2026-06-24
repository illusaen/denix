{
  wlib,
  pkgs,
  ...
}: let
  pythonScript = name: script: runtimeInputs:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = ''
        exec python3 ${script} "$@"
      '';
    };
in {
  imports = [wlib.modules.symlinkScript];

  config.package = pkgs.symlinkJoin {
    name = "niri-scripts";
    paths = [
      (pythonScript "ndrop" ./scripts/ndrop.py [
        pkgs.local.niri
        pkgs.python3
      ])
      (pythonScript "niri-workspace" ./scripts/niri-workspace.py [
        pkgs.local.niri
        pkgs.python3
      ])
    ];
  };
}
