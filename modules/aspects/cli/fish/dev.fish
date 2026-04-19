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
    set -l GITIGNORE_FILE "$NIX_CONF/templates/gitignore"
    set -l ENVRC_FILE "$NIX_CONF/templates/envrc"

    if not test -f "$FLAKE_FILE"
        echo "$NAME template doesn't exist yet."
        return 1
    end

    echo "Initializing devshell for $NAME."

    cp -f "$FLAKE_FILE" flake.nix

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

    if not test -d .git
        echo "  Initializing git repository..."
        git init
        git add -A
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

    git add -A
    echo "$NAME environment set up!"
end
