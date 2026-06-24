{
  stdenv,
  writeShellApplication,
  writeShellScriptBin,
  symlinkJoin,
  python3,
  ddcutil,
  i2c-tools,
  nix-output-monitor,
  nvd,
  lib,
  inputs,
  ...
}: let
  opnixConfig = lib.escapeShellArg (
    builtins.toJSON {
      vars = [
        {
          name = "GH_TOKEN";
          reference = "op://Service/Github/token";
        }
      ];
    }
  );

  pythonScript = name: script: runtimeInputs:
    writeShellApplication {
      inherit name runtimeInputs;
      text = ''
        exec python3 ${script} "$@"
      '';
    };
in
  symlinkJoin {
    name = "misc-scripts";
    paths = [
      (pythonScript "dconf2nix" ./scripts/dconf-to-nix.py [python3])
      (pythonScript "monitor-brightness" ./scripts/monitor-brightness.py [
        python3
        ddcutil
      ])
      (pythonScript "switcher" ./scripts/switch-input.py [
        python3
        ddcutil
        i2c-tools
      ])
      (writeShellApplication {
        name = "nb";
        runtimeInputs = [nix-output-monitor nvd];
        text = ''
          exec bash ${./scripts/nix-build.sh} "$@"
        '';
      })
      (writeShellScriptBin "load-opnix" ''
        if [ -f .env ]; then
          exit 0
        fi
        echo "Loading GITHUB_TOKEN with opnix."
        if output="$(${inputs.opnix.packages.${stdenv.hostPlatform.system}.default}/bin/opnix env -config-json ${opnixConfig} -format shell)"; then
          echo "$output" > .env
        else
          echo "WARNING: failed to resolve opnix environment variables" >&2
        fi
      '')
    ];
  }
