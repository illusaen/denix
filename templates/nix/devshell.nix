{inputs, ...}: {
  flake-file.inputs = {
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    opnix.url = "github:brizzbuzz/opnix";
  };

  imports = [inputs.devshell.flakeModule];

  perSystem = {
    config,
    pkgs,
    lib,
    inputs',
    ...
  }: {
    devshells.default = {
      commands = [
        {
          package = config.treefmt.build.wrapper;
          help = "Format all files";
        }
      ];
      packages = with pkgs; [nixd];
      devshell.startup.load-opnix.text = let
        opnixEnvConfig.vars = [
          {
            name = "GH_TOKEN";
            reference = "op://Service/Github/token";
          }
        ];
      in ''
        if [ -f .env ]; then
          exit 0
        fi
        echo "Loading GITHUB_TOKEN with opnix."
        if output="$(${inputs'.opnix.packages.default}/bin/opnix env -config-json ${lib.escapeShellArg (builtins.toJSON opnixEnvConfig)} -format shell)"; then
          echo "$output" > .env
        else
          echo "WARNING: failed to resolve opnix environment variables" >&2
        fi
      '';
      devshell.motd = "$(type -p menu &>/dev/null && menu)";
    };
  };
}
