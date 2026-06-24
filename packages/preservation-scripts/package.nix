{
  symlinkJoin,
  writeShellApplication,
  writeText,
  fd,
  jq,
}:
symlinkJoin {
  name = "preservation-scripts";
  paths = [
    (writeShellApplication {
      name = "ff";
      runtimeInputs = [
        fd
        jq
      ];
      text = "exec bash ${
        writeText "find-ephemeral-persist.sh" (
          builtins.replaceStrings
          ["@ignored@"]
          [(builtins.readFile ./scripts/ignored.json)]
          (builtins.readFile ./scripts/find-ephemeral-persist.sh)
        )
      } \"$@\"";
    })
    (writeShellApplication {
      name = "fo";
      runtimeInputs = [
        fd
        jq
      ];
      text = ''
        exec bash ${./scripts/find-orphaned-persist.sh} "$@"
      '';
    })
  ];
}
