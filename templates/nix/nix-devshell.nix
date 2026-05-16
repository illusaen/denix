{
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
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
            config.packages.link-treefmt-toml
          ]
          ++ config.pre-commit.settings.enabledPackages;
      };
    };
}
