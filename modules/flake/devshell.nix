{ inputs, den, ... }:
{
  flake-file.inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
  };

  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem =
    {
      config,
      pkgs,
      lib,
      inputs',
      ...
    }:
    let
      opnix =
        let
          buildOpnix = inputs'.opnix.packages.default;
          opnixEnvConfig.vars = [
            {
              name = "GH_TOKEN";
              reference = "op://Service/Github/token";
            }
          ];
          opnixConfig = lib.escapeShellArg (builtins.toJSON opnixEnvConfig);
        in
        pkgs.writeShellScriptBin "load-opnix" ''
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
    in
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
            "npins/"
          ];
        };
        settings.formatter.shellcheck.options = [
          "-s"
          "bash"
        ];
      };

      pre-commit.settings.hooks.treefmt.enable = true;

      devShells.default =
        let
          denApps = den.lib.nh.denApps {
            outPrefix = [ ];
            fromFlake = false;
          } pkgs;

        in
        pkgs.mkShell {
          shellHook = ''
            ${config.pre-commit.shellHook}
            load-opnix
          '';
          inputsFrom = [
            config.treefmt.build.devShell
          ];
          packages =
            denApps
            ++ [ opnix ]
            ++ config.pre-commit.settings.enabledPackages
            ++ (with pkgs; [
              nixd
              npins
              nh
            ]);
        };
    };
}
