function bb
    set -l APPLY false
    set -l OPTIONS
    set -l HOST_NAMES

    for arg in $argv
        if test "$arg" = --apply
            set APPLY true
        else if string match -q -- '-*' "$arg"
            # Split arguments containing = into separate option and value.
            if string match -q -- '*=*' "$arg"
                set -l parts (string split -m 1 '=' -- "$arg")
                set OPTIONS $OPTIONS $parts[1] $parts[2]
            else
                set OPTIONS $OPTIONS "$arg"
            end
        else
            set HOST_NAMES $HOST_NAMES "$arg"
        end
    end

    # Default to current hostname if no hosts were specified.
    if test (count $HOST_NAMES) -eq 0
        set HOST_NAMES (hostname)
    end

    if test "$APPLY" = true -a (count $HOST_NAMES) -gt 1
        echo "error: --apply only supports a single host" >&2
        return 1
    end

    set -l HOSTS
    set -l HOST_SYSTEMS

    for h in $HOST_NAMES
        set -l HOST_SYSTEM (nix eval --raw ".#hosts.$h.system" 2>/dev/null; or echo "x86_64-linux")
        set HOST_SYSTEMS $HOST_SYSTEMS "$HOST_SYSTEM"

        if string match -q -- '*darwin*' "$HOST_SYSTEM"
            set HOSTS $HOSTS ".#darwinConfigurations.$h.config.system.build.toplevel"
        else
            set HOSTS $HOSTS ".#nixosConfigurations.$h.config.system.build.toplevel"
        end
    end

    nom build --keep-going --no-link --print-out-paths --show-trace $OPTIONS $HOSTS
    or return $status

    if test "$APPLY" = true
        set -l h $HOST_NAMES[1]
        set -l HOST_SYSTEM $HOST_SYSTEMS[1]
        set -l LOCAL_HOSTNAME (hostname)

        if test "$h" != "$LOCAL_HOSTNAME"
            echo "error: --apply target '$h' does not match local hostname '$LOCAL_HOSTNAME'" >&2
            return 1
        end

        if string match -q -- '*darwin*' "$HOST_SYSTEM"
            echo "Applying darwin configuration for $h..."
            sudo -E darwin-rebuild switch --flake ".#$h"
        else
            echo "Applying NixOS configuration for $h..."
            sudo nixos-rebuild switch --flake ".#$h"
        end
    end
end
