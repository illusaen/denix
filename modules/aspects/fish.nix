{
  den,
  ...
}:
{
  den.ctx.user.includes = [ den.aspects.fish ];
  den.aspects.fish = {
    os =
      { pkgs, ... }:
      let
        fishVendorPkg = pkgs.symlinkJoin {
          name = "fish-vendor-pkg";
          paths = [
            (pkgs.stdenvNoCC.mkDerivation {
              pname = "autols-fish";
              version = "unstable-2026-04-11";

              src = pkgs.fetchFromGitHub {
                owner = "kpbaks";
                repo = "autols.fish";
                rev = "master";
                hash = "sha256-5zICkcpKkEX2D/17X5KC64Sm3cCYhkaACkUl7+9VLbg=";
              };

              installPhase = ''
                runHook preInstall

                mkdir -p $out/share/fish/vendor_{completions,conf,functions}.d

                cp completions/*.fish  $out/share/fish/vendor_completions.d/
                cp conf.d/*.fish       $out/share/fish/vendor_conf.d/
                cp functions/*.fish    $out/share/fish/vendor_functions.d/

                runHook postInstall
              '';
            })

            (pkgs.writeTextDir "share/fish/vendor_functions.d/mkd.fish" ''
              function mkd
                if test -n "$argv"
                  mkdir -p $argv
                  builtin cd $argv
                end
              end
            '')

            (pkgs.writeTextDir "share/fish/vendor_functions.d/e.fish" ''
              function e
                for editor in antigravity code-insiders codium code vim
                  if type -q $editor
                    $editor $argv
                    return
                  end
                end
                echo "No supported editor found" >&2
              end
            '')

            (pkgs.writeTextDir "share/fish/vendor_functions.d/dev.fish" ''
              function dev
                if test (count $argv) -eq 0
                  echo "Devshell initialization usage: dev <name>"
                  return 1
                end

                if test -f flake.nix
                  echo "Flake already initialized. Quitting."
                  return 0
                end

                set -l NAME $argv[1]
                set -l FLAKE_FILE "$NIX_CONF/templates/$NAME-flake.nix"

                if not test -f "$FLAKE_FILE"
                  echo "$NAME template doesn't exist yet."
                  return 1
                end

                echo "Initializing devshell for $NAME."

                cp -f "$FLAKE_FILE" flake.nix

                set -l GITIGNORE_CONTENT ".direnv\nresult\n.pre-commit-config.yaml"
                if not test -f .gitignore
                  echo "  Creating .gitignore file..."
                  echo $GITIGNORE_CONTENT > .gitignore
                else
                  if not grep -Fxq $GITIGNORE_CONTENT .gitignore
                    echo "  Adding $GITIGNORE_CONTENT to .gitignore"
                    printf "\n%s\n" $GITIGNORE_CONTENT >> .gitignore
                  end
                end

                if not test -d .git
                  echo "  Initializing git repository..."
                  git init
                  git add -A
                end

                if not test -f .envrc
                  echo "  .envrc doesn't exist, manually creating with default."
                  echo "watch_file flake.nix" > .envrc
                  echo "watch_file flake.lock" >> .envrc
                  echo "use flake" >> .envrc

                  if test "$NAME" = "python"
                    echo "layout python3" >> .envrc
                  end

                  if test "$NAME" = "node"
                    echo "layout node" >> .envrc
                  end
                end

                git add -A
                echo "$NAME environment set up!"
              end
            '')
          ];
        };
      in
      {
        environment.sessionVariables.EDITOR = "vim";
        programs.fish = {
          enable = true;
          interactiveShellInit = ''
            set -gx OP_SERVICE_ACCOUNT_TOKEN (cat /etc/opnix-token | string collect)
          '';
          shellAbbrs = {
            rmr = "rm -r";
            rmf = "rm -rf";

            cd = "n";
            cat = "bat";
          };
        };

        documentation.man.cache.enable = false;

        environment.systemPackages = with pkgs.fishPlugins; [
          puffer
          fzf-fish
          colored-man-pages
          fishVendorPkg
        ];
      };

    darwin = {
      programs.fish.interactiveShellInit = ''
        eval (/opt/homebrew/bin/brew shellenv)
      '';
    };
  };
}
