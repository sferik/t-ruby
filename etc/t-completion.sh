# Completion for Bash. Copy it in /etc/bash_completion.d or source it
# somewhere in your .bashrc

_t() {

    local cur prev completions

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    COMMANDS='accounts authorize block direct_messages direct_messages_sent\
              dm does_contain does_follow favorite favorites follow followers\
              following friends groupies help leaders list lists matrix\
              mentions open reply report_spam retweet retweets ruler search\
              set status stream timeline trend_locations trends unfollow\
              update users version whois'

    BROWSER_OPTS='-d --display-url'
    GLOBAL_OPTS='-H --host --color -U --no-ssl -P --profile'
    ID_OPTS='-i --id'
    LIST_OPTS='-c --csv -l --long -n --number -r --reverse'
    SORTED_LIST_OPTS='-c --csv -l --long -r --reverse -s --sort -u --unsorted'

    # actions
    case "${prev}" in
        accounts)
            completions=""
            ;;
        authorize)
            completions="$BROWSER_OPTS"
            ;;
        block)
            completions="$ID_OPTS"
            ;;
        direct_messages)
            completions="$LIST_OPTS"
            ;;
        direct_messages_sent)
            completions="$LIST_OPTS"
            ;;
        dm)
            completions="$ID_OPTS"
            ;;
        does_contain)
            completions="$ID_OPTS"
            ;;
        does_follow)
            completions="$ID_OPTS"
            ;;
        favorite)
            completions=""
            ;;
        favorites)
            completions="$ID_OPTS $LIST_OPTS"
            ;;
        follow)
            completions="$ID_OPTS"
            ;;
        followers)
            completions="$ID_OPTS $SORTED_LIST_OPTS"
            ;;
        following)
            completions="$ID_OPTS $SORTED_LIST_OPTS"
            ;;
        friends)
            completions="$ID_OPTS $SORTED_LIST_OPTS"
            ;;
        groupies)
            completions="$ID_OPTS $SORTED_LIST_OPTS"
            ;;
        help)
            completions=""
            ;;
        leaders)
            completions="$ID_OPTS $SORTED_LIST_OPTS"
            ;;
        list)
            completions=""
            ;;
        lists)
            completions="$ID_OPTS $SORTED_LIST_OPTS"
            ;;
        matrix)
            completions=""
            ;;
        mentions)
            completions="$LIST_OPTS"
            ;;
        open)
            completions="$ID_OPTS $BROWSER_OPTS -s --status"
            ;;
        reply)
            completions="-a --all -l --location"
            ;;
        report_spam)
            completions="$ID_OPTS"
            ;;
        retweet)
            completions=""
            ;;
        retweets)
            completions="$ID_OPTS $LIST_OPTS"
            ;;
        ruler)
            completions="-i --indent"
            ;;
        search)
            completions=""
            ;;
        set)
            completions=""
            ;;
        status)
            completions="-c --csv -l --long"
            ;;
        stream)
            completions=""
            ;;
        timeline)
            completions="$ID_OPTS $LIST_OPTS -e --exclude -s --since-id"
            ;;
        trend_locations)
            completions="$LIST_OPTS"
            ;;
        trends)
            completions="-x --exclude-hashtags"
            ;;
        unfollow)
            completions="$ID_OPTS"
            ;;
        update)
            completions="-l --location -f --file"
            ;;
        users)
            completions="$ID_OPTS $SORTED_LIST_OPTS"
            ;;
        version)
            completions=""
            ;;
        whois)
            completions="$ID_OPTS -c --csv -l --long"
            ;;
        *)
            completions="$COMMANDS"
            ;;

    esac

    COMPREPLY=( $( compgen -W "$GLOBAL_OPTS $completions" -- $cur ))
    return 0
}

[ -n "${have:-}" ] && complete -F _t $filenames t
