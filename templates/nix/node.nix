{
  perSystem =
    { pkgs, ... }:
    {
      pre-commit.settings.hooks.eslint.enable = true;
      treefmt.programs.prettier = {
        enable = true;
        includes = [
          "*.svelte"
          "*.js"
          "*.jsx"
          "*.ts"
          "*.tsx"
        ];
        settings = {
          plugins = [ "prettier-plugin-svelte" ];
          bracketSameLine = false;
          bracketSpacing = true;
          htmlWhitespaceSensitivity = "css";
          semi = true;
          jsxSingleQuote = true;
          singleQuote = true;
          trailingComma = "all";
        };
      };
      treefmt.programs.jsonfmt = {
        enable = true;
        excludes = [
          "package*.json"
          "tsconfig*.json"
        ];
      };

      devshells.default = {
        packages = with pkgs; [
          nodejs_latest
          pnpm
          playwright-driver
        ];
        devshell.startup.initPnpmScript.text = ''
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
      };
    };
}
