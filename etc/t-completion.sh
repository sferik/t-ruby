# Completion for Bash. Copy it in /etc/bash_completion.d/ or source it
    # somewhere in your ~/.bashrc

    _t() {

      local cur prev completions

      COMPREPLY=()
      cur=${COMP_WORDS[COMP_CWORD]}
      topcmd=${COMP_WORDS[1]}
      prev=${COMP_WORDS[COMP_CWORD-1]}

      COMMANDS='accounts authorize block direct_messages direct_messages_sent dm does_contain does_follow favorite favorites follow followings followings_following followers friends groupies intersection leaders lists matrix mentions open reply report_spam retweet retweets retweets_of_me ruler status timeline trends trend_locations unfollow update users version whois whoami delete list search set stream'

      case "$topcmd" in
        accounts) completions='-H --host -C --color -U --no-ssl -P --profile';;
authorize) completions='--display-uri --d -H --host -C --color -U --no-ssl -P --profile';;
block) completions='--id --i -H --host -C --color -U --no-ssl -P --profile';;
direct_messages) completions='--csv --c --decode_uris --d --long --l --number --n --relative_dates --a --reverse --r -H --host -C --color -U --no-ssl -P --profile';;
direct_messages_sent) completions='--csv --c --decode_uris --d --long --l --number --n --relative_dates --a --reverse --r -H --host -C --color -U --no-ssl -P --profile';;
dm) completions='--id --i -H --host -C --color -U --no-ssl -P --profile';;
does_contain) completions='--id --i -H --host -C --color -U --no-ssl -P --profile';;
does_follow) completions='--id --i -H --host -C --color -U --no-ssl -P --profile';;
favorite) completions='-H --host -C --color -U --no-ssl -P --profile';;
favorites) completions='--csv --c --decode_uris --d --id --i --long --l --max_id --m --number --n --relative_dates --a --reverse --r --since_id --s -H --host -C --color -U --no-ssl -P --profile';;
follow) completions='--id --i -H --host -C --color -U --no-ssl -P --profile';;
followings) completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host -C --color -U --no-ssl -P --profile';;
followings_following) completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host -C --color -U --no-ssl -P --profile';;
followers) completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host -C --color -U --no-ssl -P --profile';;
friends) completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host -C --color -U --no-ssl -P --profile';;
groupies) completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host -C --color -U --no-ssl -P --profile';;
intersection) completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --type --t --unsorted --u -H --host -C --color -U --no-ssl -P --profile';;
leaders) completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host -C --color -U --no-ssl -P --profile';;
lists) completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host -C --color -U --no-ssl -P --profile';;
matrix) completions='-H --host -C --color -U --no-ssl -P --profile';;
mentions) completions='--csv --c --decode_uris --d --long --l --number --n --relative_dates --a --reverse --r -H --host -C --color -U --no-ssl -P --profile';;
open) completions='--display-uri --d --id --i --status --s -H --host -C --color -U --no-ssl -P --profile';;
reply) completions='--all --a --location --l -H --host -C --color -U --no-ssl -P --profile';;
report_spam) completions='--id --i -H --host -C --color -U --no-ssl -P --profile';;
retweet) completions='-H --host -C --color -U --no-ssl -P --profile';;
retweets) completions='--csv --c --decode_uris --d --id --i --long --l --number --n --relative_dates --a --reverse --r -H --host -C --color -U --no-ssl -P --profile';;
retweets_of_me) completions='--csv --c --decode_uris --d --id --i --long --l --number --n --relative_dates --a --reverse --r -H --host -C --color -U --no-ssl -P --profile';;
ruler) completions='--indent --i -H --host -C --color -U --no-ssl -P --profile';;
status) completions='--csv --c --decode_uris --d --long --l --relative_dates --a -H --host -C --color -U --no-ssl -P --profile';;
timeline) completions='--csv --c --decode_uris --d --exclude --e --id --i --long --l --max_id --m --number --n --relative_dates --a --reverse --r --since_id --s -H --host -C --color -U --no-ssl -P --profile';;
trends) completions='--exclude-hashtags --x -H --host -C --color -U --no-ssl -P --profile';;
trend_locations) completions='--csv --c --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host -C --color -U --no-ssl -P --profile';;
unfollow) completions='--id --i -H --host -C --color -U --no-ssl -P --profile';;
update) completions='--location --l --file --f -H --host -C --color -U --no-ssl -P --profile';;
users) completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host -C --color -U --no-ssl -P --profile';;
version) completions='-H --host -C --color -U --no-ssl -P --profile';;
whois) completions='--csv --c --decode_uris --d --id --i --long --l --relative_dates --a -H --host -C --color -U --no-ssl -P --profile';;
whoami) completions='--csv --c --decode_uris --d --long --l --relative_dates --a -H --host -C --color -U --no-ssl -P --profile';;
delete)
                    case "$prev" in
                    delete) completions='block dm favorite list status help';;
                    block) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
dm) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
favorite) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
list) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
status) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
help) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
                    *) completions='-H --host -C --color -U --no-ssl -P --profile';;
                    esac;;

list)
                    case "$prev" in
                    list) completions='add create information members remove timeline help';;
                    add) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
create) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
information) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
members) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
remove) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
timeline) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
help) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
                    *) completions='-H --host -C --color -U --no-ssl -P --profile';;
                    esac;;

search)
                    case "$prev" in
                    search) completions='all favorites list mentions retweets timeline users help';;
                    all) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
favorites) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
list) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
mentions) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
retweets) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
timeline) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
users) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
help) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
                    *) completions='-H --host -C --color -U --no-ssl -P --profile';;
                    esac;;

set)
                    case "$prev" in
                    set) completions='active bio language location name profile_background_image profile_image website help';;
                    active) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
bio) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
language) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
location) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
name) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
profile_background_image) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
profile_image) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
website) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
help) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
                    *) completions='-H --host -C --color -U --no-ssl -P --profile';;
                    esac;;

stream)
                    case "$prev" in
                    stream) completions='all list matrix search timeline users help';;
                    all) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
list) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
matrix) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
search) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
timeline) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
users) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
help) completions='-H --host -C --color -U --no-ssl -P --profile' ;;
                    *) completions='-H --host -C --color -U --no-ssl -P --profile';;
                    esac;;

        *) completions="$COMMANDS" ;;
      esac

      COMPREPLY=( $( compgen -W "$completions" -- $cur ))
      return 0

    }

    complete -F _t $filenames t
    