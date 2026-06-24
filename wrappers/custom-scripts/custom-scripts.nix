{
  config,
  wlib,
  pkgs,
  lib,
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
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = ''
        exec python3 ${script} "$@"
      '';
    };
in {
  imports = [wlib.modules.symlinkScript];

  options.opnixPackage = lib.mkOption {type = lib.types.package;};

  config.package = pkgs.symlinkJoin {
    name = "custom-scripts";
    paths = [
      (pythonScript "dconf2nix" ./scripts/dconf-to-nix.py [pkgs.python3])
      (pythonScript "monitor-brightness" ./scripts/monitor-brightness.py [
        pkgs.ddcutil
        pkgs.python3
      ])
      (pythonScript "switcher" ./scripts/switch-input.py [
        pkgs.ddcutil
        pkgs.i2c-tools
        pkgs.python3
      ])
      (pkgs.writeShellApplication {
        name = "nb";
        runtimeInputs = with pkgs; [nix-output-monitor nvd];
        text =
          builtins.replaceStrings
          [
            "@nom@"
            "@nvd@"
          ]
          [
            (lib.getExe pkgs.nix-output-monitor)
            (lib.getExe pkgs.nvd)
          ]
          (builtins.readFile ./scripts/nix-build.sh);
      })
      (pkgs.writeShellScriptBin "load-opnix" ''
        if [ -f .env ]; then
          exit 0
        fi
        echo "Loading GITHUB_TOKEN with opnix."
        if output="$(${config.opnixPackage}/bin/opnix env -config-json ${opnixConfig} -format shell)"; then
          echo "$output" > .env
        else
          echo "WARNING: failed to resolve opnix environment variables" >&2
        fi
      '')
    ];
  };
}
