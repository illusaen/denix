{
  inputs,
  ...
}:
{
  flake-file.inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = _: {
    treefmt = {
      projectRootFile = ".git/config";
      flakeCheck = false;
      programs = {
        fish_indent.enable = true;
        nixfmt.enable = true;
        deadnix.enable = true;
        statix.enable = true;
        nixf-diagnose.enable = true;
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
          "pnpm-lock.yaml"
          "/node_modules"
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
    };
  };
}
