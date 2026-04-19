{ inputs, den, ... }:
{
  flake-file.inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem =
    {
      config,
      pkgs,
      lib,
      inputs',
      ...
    }:
    {
      treefmt = {
        flakeCheck = true;
        projectRoot = ../../.;
        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;
          shellcheck = {
            enable = true;
            excludes = [ ".envrc" ];
          };
          fish_indent.enable = true;
        };
        settings.global = {
          on-unmatched = "debug";
          excludes = [
            ".git"
            "*.lock"
            ".gitignore"
          ];
        };
        settings.formatter.shellcheck.options = [
          "-s"
          "bash"
        ];
      };

      devShells.default =
        let
          denApps = den.lib.nh.denApps {
            outPrefix = [ ];
            fromFlake = false;
          } pkgs;

          buildOpnix = inputs'.opnix.packages.default;
          opnixEnvConfig.vars = [
            {
              name = "GH_TOKEN";
              reference = "op://Service/Github/token";
            }
          ];
          opnixConfig = lib.escapeShellArg (builtins.toJSON opnixEnvConfig);
        in
        pkgs.mkShell {
          shellHook = ''
            if [ -f .env ]; then
              exit 0
            fi
            echo "Loading GITHUB_TOKEN with opnix."
            if output="$(${buildOpnix}/bin/opnix env -config-json ${opnixConfig} -format shell)"; then
              echo "$output" > .env
            else
              echo "WARNING: failed to resolve opnix environment variables" >&2
            fi
          '';
          inputsFrom = [
            config.treefmt.build.devShell
          ];
          packages =
            denApps
            ++ (with pkgs; [
              nixd
              npins
              nh
            ]);
        };
    };
}
