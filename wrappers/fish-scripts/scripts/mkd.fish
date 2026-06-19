function mkd
    if test -n "$argv"
        mkdir -p $argv
        builtin cd $argv
    end
end
