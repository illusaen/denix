{
  inputs,
  ...
}:
{
  flake-file.inputs.devshell = {
    url = "github:numtide/devshell";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [
    inputs.devshell.flakeModule
  ];

  perSystem =
    { config, pkgs, ... }:
    {
      devshells.default = {
        commands = [
          {
            package = config.treefmt.build.wrapper;
            help = "Format all files";
          }
          {
            package = pkgs.nix-tree;
            help = "Interactively browse dependency graphs of Nix derivations";
          }
          {
            package = pkgs.nix-diff;
            help = "Explain why two Nix derivations differ";
          }
          {
            package = config.packages.nix-build;
            name = "nix-build";
            help = "Build a host configuration with nb";
          }
        ];
        packages =
          config.pre-commit.settings.enabledPackages
          ++ (with pkgs; [
            nixd
            config.packages.opnix-load
          ]);
        devshell.startup.load-opnix.text = "load-opnix";
        devshell.motd = "$(type -p menu &>/dev/null && menu)";
      };
    };
}
