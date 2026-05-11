_: {
  flake-file.inputs.rust-overlay = {
    url = "github:oxalica/rust-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  perSystem =
    {
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

      treefmt.programs.rustfmt.enable = true;
      pre-commit.settings.hooks.clippy.enable = true;

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          rust-bin.stable.latest.default
        ];
      };
    };
}
