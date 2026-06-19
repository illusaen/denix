function dev
    if test (count $argv) -eq 0
        echo "Devshell initialization usage: dev <name>"
        return 1
    end

    if test -f nix/devshell.nix
        echo "Flake already initialized. Quitting."
        return 0
    end

    set -l NAME $argv[1]
    set -l NIX_CONF_ROOT (string replace -r '^~' "$HOME" -- "$NIX_CONF")
    set -l TEMPLATE_ROOT "$NIX_CONF_ROOT/templates"
    set -l LANGUAGE_FILE "$TEMPLATE_ROOT/nix/$NAME.nix"

    if not test -f "$LANGUAGE_FILE"
        echo "$NAME template at $LANGUAGE_FILE doesn't exist yet."
        return 1
    end

    echo "Initializing devshell for $NAME."

    mkdir -p nix
    cp -f "$LANGUAGE_FILE" "nix/$NAME.nix"
    cp -f "$TEMPLATE_ROOT/nix/{devshell,flake-file,pre-commit,treefmt}.nix" nix/

    set -l GITIGNORE_CONTENT ".direnv\nresult\n.pre-commit-config.yaml\ntreefmt.toml"
    if not test -f .gitignore
        echo "  Creating .gitignore file..."
        cp "$TEMPLATE_ROOT/gitignore" .gitignore
    else
        if not grep -Fxq $GITIGNORE_CONTENT .gitignore
            echo "  Adding $GITIGNORE_CONTENT to .gitignore"
            printf "\n%s\n" $GITIGNORE_CONTENT >>.gitignore
        end
    end

    if not test -f .envrc
        echo "  .envrc doesn't exist, manually creating with default."
        cp "$TEMPLATE_ROOT/envrc" .envrc

        if test "$NAME" = python
            echo "layout python3" >>.envrc
        end

        if test "$NAME" = node
            echo "layout node" >>.envrc
        end
    end

    if not test -d .git
        echo "  Initializing git repository..."
        git init
        git add -A
    end

    echo "$NAME environment set up!"
end
