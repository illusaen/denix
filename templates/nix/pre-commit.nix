{ inputs, ... }:
{
  flake-file.inputs.git-hooks-nix = {
    url = "github:cachix/git-hooks.nix";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
  imports = [ inputs.git-hooks-nix.flakeModule ];

  perSystem =
    {
      config,
      self',
      inputs',
      pkgs,
      ...
    }:
    {
      pre-commit.settings = {
        package = inputs'.git-hooks-nix.packages.prek or pkgs.prek;
        hooks.treefmt = {
          enable = true;
          package = self'.formatter;
        };
      };
      devshells.default = {
        packages = config.pre-commit.settings.enabledPackages;
        devshell.startup.pre-commit.text = config.pre-commit.installationScript;
      };
    };
}
