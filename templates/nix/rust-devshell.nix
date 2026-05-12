{
  flake-file.inputs.rust-overlay = {
    url = "github:oxalica/rust-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  perSystem =
    {
      pkgs,
      system,
      inputs,
      config,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.rust-overlay.overlays.default ];
      };

      treefmt.programs.rustfmt.enable = true;
      pre-commit.settings.hooks.clippy.enable = true;

      devShells.default = pkgs.mkShell {
        shellHook = ''
          ${config.pre-commit.shellHook}
          link-treefmt-toml
        '';
        inputsFrom = [
          config.treefmt.build.devShell
        ];
        packages =
          with pkgs;
          [
            nixd
            npins
            nodejs_latest
            pnpm
            config.packages.link-treefmt-toml
            rust-bin.stable.latest.default
          ]
          ++ config.pre-commit.settings.enabledPackages;
      };
    };
}
