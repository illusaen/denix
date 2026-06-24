{
  wlib,
  pkgs,
  ...
}: {
  imports = [wlib.modules.symlinkScript];

  config.package = pkgs.symlinkJoin {
    name = "preservation-scripts";
    paths = [
      (pkgs.writeShellApplication {
        name = "ff";
        runtimeInputs = with pkgs; [
          fd
          jq
        ];
        text = "exec bash ${
          pkgs.writeText "find-ephemeral-persist.sh" (
            builtins.replaceStrings
            ["@ignored@"]
            [(builtins.readFile ./scripts/ignored.json)]
            (builtins.readFile ./scripts/find-ephemeral-persist.sh)
          )
        } \"$@\"";
      })
      (pkgs.writeShellApplication {
        name = "fo";
        runtimeInputs = with pkgs; [
          fd
          jq
        ];
        text = ''
          exec bash ${./scripts/find-orphaned-persist.sh} "$@"
        '';
      })
    ];
  };
}
