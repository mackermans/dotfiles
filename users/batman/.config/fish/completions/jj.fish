function __jj_bookmark_set_complete
    jj bookmark list -T 'name ++ "\n"' 2>/dev/null
end

complete -c jj -n "__fish_seen_subcommand_from bookmark; and __fish_seen_subcommand_from set" -a "(__jj_bookmark_set_complete)" -f
complete -c jj -n "__fish_seen_subcommand_from new" -a "(__jj_bookmark_set_complete)" -f

