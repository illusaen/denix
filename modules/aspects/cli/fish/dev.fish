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
    set -l DEVSHELL_FILE "$NIX_CONF/templates/nix/$NAME-devshell.nix"
    set -l GITIGNORE_FILE "$NIX_CONF/templates/gitignore"
    set -l ENVRC_FILE "$NIX_CONF/templates/envrc"

    if not test -f "$DEVSHELL_FILE"
        echo "$NAME template at $DEVSHELL_FILE doesn't exist yet."
        return 1
    end

    echo "Initializing devshell for $NAME."

    mkdir -p nix
    cp -f "$DEVSHELL_FILE" nix/devshell.nix
    cp -f "$NIX_CONF/templates/nix/default.nix" nix/default.nix

    cp -r "$NIX_CONF/templates/nix/npins" .
    cp "$NIX_CONF/templates/nix/default.nix" default.nix
    cp "$NIX_CONF/templates/nix/flake.nix" flake.nix
    cp "$NIX_CONF/templates/nix/shell.nix" shell.nix

    set -l GITIGNORE_CONTENT ".direnv\nresult\n.pre-commit-config.yaml"
    if not test -f .gitignore
        echo "  Creating .gitignore file..."
        cp $GITIGNORE_FILE .gitignore
    else
        if not grep -Fxq $GITIGNORE_CONTENT .gitignore
            echo "  Adding $GITIGNORE_CONTENT to .gitignore"
            printf "\n%s\n" $GITIGNORE_CONTENT >>.gitignore
        end
    end

    if not test -f .envrc
        echo "  .envrc doesn't exist, manually creating with default."
        cp $ENVRC_FILE .envrc

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
