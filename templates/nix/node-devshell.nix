{ inputs, ... }:
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
      ...
    }:
    let
      initPnpmScript = pkgs.writeShellScript "init-pnpm.sh" ''
        function _pnpm-install()
        {
          # Avoid running "pnpm install" for every shell.
          # Only run it when the "package-lock.json" file or nodejs version has changed.
          # We do this by storing the nodejs version and a hash of "package-lock.json" in node_modules.
          local ACTUAL_PNPM_CHECKSUM="$(${pkgs.pnpm}/bin/pnpm --version):$(${pkgs.nix}/bin/nix-hash --type sha256 pnpm-lock.yaml)"
          local PNPM_CHECKSUM_FILE="./node_modules/pnpm-lock.yaml.checksum"
          if [ -f "$PNPM_CHECKSUM_FILE" ]
            then
              read -r EXPECTED_PNPM_CHECKSUM < "$PNPM_CHECKSUM_FILE"
            else
              EXPECTED_PNPM_CHECKSUM=""
          fi

          if [ "$ACTUAL_PNPM_CHECKSUM" != "$EXPECTED_PNPM_CHECKSUM" ]
          then
            if ${pkgs.pnpm}/bin/pnpm install
            then
              echo "$ACTUAL_PNPM_CHECKSUM" > "$PNPM_CHECKSUM_FILE"
            else
              echo "Install failed. Run 'pnpm install' manually."
            fi
          fi
        }

        if [ ! -f package.json ]
        then
          echo "No package.json found. Run 'pnpm init' to create one." >&2
        else
          _pnpm-install
        fi
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
          prettier = {
            enable = true;
            settings = {
              bracketSameLine = true;
              bracketSpacing = true;
              semi = true;
              singleQuote = true;
              trailingComma = "all";
            };
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

      pre-commit.settings.hooks = {
        treefmt.enable = true;
        eslint = {
          enable = true;
          settings.extensions = "\\.(j|t)sx?$";
        };
      };

      devShells.default = pkgs.mkShell {
        shellHook = ''
                      ${config.pre-commit.shellHook}
          source ${initPnpmScript}
        '';
        inputsFrom = [
          config.treefmt.build.devShell
        ];
        packages =
          config.pre-commit.settings.enabledPackages
          ++ (with pkgs; [
            nixd
            npins
            nodejs_latest
            pnpm
          ]);
      };
    };
}
