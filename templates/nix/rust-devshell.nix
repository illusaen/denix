{ inputs, ... }:
{
  flake-file.inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem =
    {
      config,
      pkgs,
      system,
      inputs,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.rust-overlay.overlays.default ];
      };

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
          rustfmt.enable = true;
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

      pre-commit.settings.hooks = {
        treefmt.enable = true;
        clippy.enable = true;
      };

      devShells.default = pkgs.mkShell {
        shellHook = ''
          ${config.pre-commit.shellHook}
        '';
        inputsFrom = [
          config.treefmt.build.devShell
        ];
        packages =
          config.pre-commit.settings.enabledPackages
          ++ (with pkgs; [
            nixd
            npins
            rust-bin.stable.latest.default
          ]);
      };
    };
}
