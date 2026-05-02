function e
    for editor in zeditor antigravity code vim
        if type -q $editor
            $editor $argv
            return
        end
    end
    echo "No supported editor found" >&2
end
