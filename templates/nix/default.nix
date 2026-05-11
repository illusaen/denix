{ inputs, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.flakeless-parts
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks-nix.flakeModule
  ];

  systems = [
    "aarch64-darwin"
    "x86_64-linux"
  ];

  flake-file.inputs = {
    flake-file.url = "github:vic/flake-file";
    import-tree.url = "github:vic/import-tree";
    with-inputs.url = "github:vic/with-inputs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
  };

  perSystem =
    { pkgs, config, ... }:
    let
      link-treefmt-toml = pkgs.writeShellScriptBin "link-treefmt-toml" ''
        PROJECT_ROOT=$(pwd) 
        if [ ! -d "$PROJECT_ROOT" ] || [ -e "$PROJECT_ROOT/treefmt.toml" ]; then
          exit 0
        fi
        ln -s ${config.treefmt.build.configFile} "$PROJECT_ROOT/treefmt.toml"
        echo "treefmt.toml linked."
      '';
    in
    {
      treefmt = {
        flakeCheck = true;
        projectRoot = ../.;
        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;
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
            "npins/"
          ];
        };
        settings.formatter.shellcheck.options = [
          "-s"
          "bash"
        ];
      };

      pre-commit.settings.hooks.treefmt.enable = true;

      devShells.default = pkgs.mkShell {
        shellHook = ''
          ${config.pre-commit.shellHook}
          link-treefmt-toml
        '';
        inputsFrom = [
          config.treefmt.build.devShell
        ];
        packages = [
          link-treefmt-toml
        ]
        ++ config.pre-commit.settings.enabledPackages
        ++ (with pkgs; [
          nixd
        ]);
      };
    };
}
