{
  inputs,
  writeShellScriptBin,
  stdenv,
  lib,
}:
let
  buildOpnix = inputs.opnix.packages.${stdenv.hostPlatform.system}.default;
  opnixEnvConfig.vars = [
    {
      name = "GH_TOKEN";
      reference = "op://Service/Github/token";
    }
  ];
  opnixConfig = lib.escapeShellArg (builtins.toJSON opnixEnvConfig);
in
writeShellScriptBin "load-opnix" ''
  if [ -f .env ]; then
    exit 0
  fi
  echo "Loading GITHUB_TOKEN with opnix."
  if output="$(${buildOpnix}/bin/opnix env -config-json ${opnixConfig} -format shell)"; then
    echo "$output" > .env
  else
    echo "WARNING: failed to resolve opnix environment variables" >&2
  fi
''
