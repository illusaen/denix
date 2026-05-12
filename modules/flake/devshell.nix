{
  inputs,
  den,
  ...
}:
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

      link-treefmt-toml = pkgs.writeShellScriptBin "link-treefmt-toml" ''
        PROJECT_ROOT=$(pwd) 
        if [ ! -d "$PROJECT_ROOT" ]; then
          exit 0
        fi
        ln -sf ${config.treefmt.build.configFile} "$PROJECT_ROOT/treefmt.toml"
        echo "treefmt.toml linked."
      '';
    in
    {
      treefmt = {
        flakeCheck = true;
        projectRoot = ../../.;
        programs = {
          nixfmt = {
            enable = true;
            width = 120;
          };
          deadnix.enable = true;
          statix.enable = true;
          shellcheck = {
            enable = true;
            excludes = [
              ".envrc"
            ];
          };
          stylua = {
            enable = true;
            settings = {
              collapse_simple_statement = "Always";
              indent_type = "Spaces";
              indent_width = 2;
              quote_style = "AutoPreferDouble";
              sort_requires.enabled = true;
            };
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
            "modules/aspects/vscode/settings.json"
            "modules/aspects/desktop/hypr/config.lua"
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
            link-treefmt-toml
          '';
          inputsFrom = [
            config.treefmt.build.devShell
          ];
          packages =
            denApps
            ++ [
              opnix
              link-treefmt-toml
            ]
            ++ config.pre-commit.settings.enabledPackages
            ++ (with pkgs; [
              nixd
              npins
              nh
            ]);
        };
    };
}
