{
  writeShellApplication,
  replaceVars,
  fd,
  jq,
  persistMount ? "/persisted",
  persisted ? builtins.toJSON {
    directories = [ ];
    files = [ ];
  },
}:
let
  script = replaceVars ./find-orphaned-persist.sh {
    inherit persistMount persisted;
  };
in
writeShellApplication {
  name = "fo";
  runtimeInputs = [
    fd
    jq
  ];
  text = ''
    exec bash ${script} "$@"
  '';
}
