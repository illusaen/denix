{ inputs, ... }:
{
  flake-file.inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  imports = [
    inputs.git-hooks-nix.flakeModule
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
        flakeCheck = false;
        programs = {
          nixfmt.enable = true;
          shellcheck = {
            enable = true;
            excludes = [ ".envrc" ];
          };
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

      pre-commit.settings.hooks = {
        treefmt = {
          enable = true;
          packageOverrides.treefmt = config.treefmt.build.wrapper;
        };
        deadnix.enable = true;
        statix.enable = false;
      };

      devShells.default =
        let
          buildOpnix = inputs'.opnix.packages.default;
          opnixEnvConfig.vars = [
            {
              name = "GITHUB_TOKEN";
              reference = "op://Service/Github/token";
            }
          ];
          opnixConfig = lib.escapeShellArg (builtins.toJSON opnixEnvConfig);
        in
        pkgs.mkShell {
          shellHook = config.pre-commit.installationScript + ''
            if [ -f ".env" ]; then
              exit 0
            else
              echo "Loading GITHUB_TOKEN with opnix."
              if output="$(${buildOpnix}/bin/opnix env -config-json ${opnixConfig} -format shell)"; then
                echo "$output" > .env
              else
                echo "WARNING: failed to resolve opnix environment variables" >&2
              fi
            fi
          '';
          inputsFrom = [
            config.treefmt.build.devShell
            config.pre-commit.devShell
          ];
          packages = [ pkgs.nixd ];
        };
    };
}
