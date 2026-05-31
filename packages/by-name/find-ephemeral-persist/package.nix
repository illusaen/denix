{
  writeShellApplication,
  fd,
  jq,
  replaceVars,
  persisted ? builtins.toJSON {
    directories = [ ];
    files = [ ];
  },
}:
let
  script = replaceVars ./find-ephemeral-persist.sh {
    inherit persisted;
    ignored = builtins.readFile ./ignored.json;
  };
in
writeShellApplication {
  name = "ff";
  runtimeInputs = [
    fd
    jq
  ];
  text = ''
    exec bash ${script} "$@"
  '';
}
