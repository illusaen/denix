{
  inputs,
  ...
}:
{
  flake-file.inputs.treefmt-nix.url = "github:numtide/treefmt-nix";

  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    {
      config,
      ...
    }:
    {
      treefmt = {
        projectRootFile = ".git/config";
        flakeCheck = false;
        programs = {
          fish_indent.enable = true;
          nixfmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;
          nixf-diagnose.enable = true;
          shellcheck = {
            enable = true;
          };
          toml-sort.enable = true;
          ruff = {
            check = true;
            format = true;
          };
        };
        settings.global = {
          on-unmatched = "debug";
          excludes = [
            ".secrets/**"
            "*.editorconfig"
            "*.envrc"
            "*.gitconfig"
            "*.gitignore"
            "*flake.lock"
            "*.svg"
            "*.png"
            "*.gif"
            "*.ico"
            "*.jpg"
            "*.webp"
            "*.conf"
            "*.age"
            "*.pub"
            "*.asc"
            "*.org"
            "*.zsh"
            "*.kdl"
            "*.txt"
            "*.tmpl"
            "*.jwe"
            "*.xml"
            "*.dds"
            "*.diff"
            "*.bin"
            # Underscore-prefixed files/dirs are ignored by the module auto-import system
            "**/_*/**"
            "**/_*"
          ];
        };
        settings.formatter.shellcheck.options = [
          "-s"
          "bash"
        ];
      };

      devshells.default.packagesFrom = [
        config.treefmt.build.devShell
      ];
    };
}
