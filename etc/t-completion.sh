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
        accounts)
        case "$prev" in
            accounts)
                completions='';;
            
            *)
                completions='-H --host --color -U --no-ssl -P --profile';;
        esac;;

authorize)
        case "$prev" in
            authorize)
                completions='';;
            
            *)
                completions='--display-uri --d -H --host --color -U --no-ssl -P --profile';;
        esac;;

block)
        case "$prev" in
            block)
                completions='';;
            
            *)
                completions='--id --i -H --host --color -U --no-ssl -P --profile';;
        esac;;

direct_messages)
        case "$prev" in
            direct_messages)
                completions='';;
            
            *)
                completions='--csv --c --decode_uris --d --long --l --number --n --relative_dates --a --reverse --r -H --host --color -U --no-ssl -P --profile';;
        esac;;

direct_messages_sent)
        case "$prev" in
            direct_messages_sent)
                completions='';;
            
            *)
                completions='--csv --c --decode_uris --d --long --l --number --n --relative_dates --a --reverse --r -H --host --color -U --no-ssl -P --profile';;
        esac;;

dm)
        case "$prev" in
            dm)
                completions='';;
            
            *)
                completions='--id --i -H --host --color -U --no-ssl -P --profile';;
        esac;;

does_contain)
        case "$prev" in
            does_contain)
                completions='';;
            
            *)
                completions='--id --i -H --host --color -U --no-ssl -P --profile';;
        esac;;

does_follow)
        case "$prev" in
            does_follow)
                completions='';;
            
            *)
                completions='--id --i -H --host --color -U --no-ssl -P --profile';;
        esac;;

favorite)
        case "$prev" in
            favorite)
                completions='';;
            
            *)
                completions='-H --host --color -U --no-ssl -P --profile';;
        esac;;

favorites)
        case "$prev" in
            favorites)
                completions='';;
            
            *)
                completions='--csv --c --decode_uris --d --id --i --long --l --max_id --m --number --n --relative_dates --a --reverse --r --since_id --s -H --host --color -U --no-ssl -P --profile';;
        esac;;

follow)
        case "$prev" in
            follow)
                completions='';;
            
            *)
                completions='--id --i -H --host --color -U --no-ssl -P --profile';;
        esac;;

followings)
        case "$prev" in
            followings)
                completions='';;
            
            *)
                completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host --color -U --no-ssl -P --profile';;
        esac;;

followings_following)
        case "$prev" in
            followings_following)
                completions='';;
            
            *)
                completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host --color -U --no-ssl -P --profile';;
        esac;;

followers)
        case "$prev" in
            followers)
                completions='';;
            
            *)
                completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host --color -U --no-ssl -P --profile';;
        esac;;

friends)
        case "$prev" in
            friends)
                completions='';;
            
            *)
                completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host --color -U --no-ssl -P --profile';;
        esac;;

groupies)
        case "$prev" in
            groupies)
                completions='';;
            
            *)
                completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host --color -U --no-ssl -P --profile';;
        esac;;

intersection)
        case "$prev" in
            intersection)
                completions='';;
            
            *)
                completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --type --t --unsorted --u -H --host --color -U --no-ssl -P --profile';;
        esac;;

leaders)
        case "$prev" in
            leaders)
                completions='';;
            
            *)
                completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host --color -U --no-ssl -P --profile';;
        esac;;

lists)
        case "$prev" in
            lists)
                completions='';;
            
            *)
                completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host --color -U --no-ssl -P --profile';;
        esac;;

matrix)
        case "$prev" in
            matrix)
                completions='';;
            
            *)
                completions='-H --host --color -U --no-ssl -P --profile';;
        esac;;

mentions)
        case "$prev" in
            mentions)
                completions='';;
            
            *)
                completions='--csv --c --decode_uris --d --long --l --number --n --relative_dates --a --reverse --r -H --host --color -U --no-ssl -P --profile';;
        esac;;

open)
        case "$prev" in
            open)
                completions='';;
            
            *)
                completions='--display-uri --d --id --i --status --s -H --host --color -U --no-ssl -P --profile';;
        esac;;

reply)
        case "$prev" in
            reply)
                completions='';;
            
            *)
                completions='--all --a --location --l -H --host --color -U --no-ssl -P --profile';;
        esac;;

report_spam)
        case "$prev" in
            report_spam)
                completions='';;
            
            *)
                completions='--id --i -H --host --color -U --no-ssl -P --profile';;
        esac;;

retweet)
        case "$prev" in
            retweet)
                completions='';;
            
            *)
                completions='-H --host --color -U --no-ssl -P --profile';;
        esac;;

retweets)
        case "$prev" in
            retweets)
                completions='';;
            
            *)
                completions='--csv --c --decode_uris --d --id --i --long --l --number --n --relative_dates --a --reverse --r -H --host --color -U --no-ssl -P --profile';;
        esac;;

retweets_of_me)
        case "$prev" in
            retweets_of_me)
                completions='';;
            
            *)
                completions='--csv --c --decode_uris --d --id --i --long --l --number --n --relative_dates --a --reverse --r -H --host --color -U --no-ssl -P --profile';;
        esac;;

ruler)
        case "$prev" in
            ruler)
                completions='';;
            
            *)
                completions='--indent --i -H --host --color -U --no-ssl -P --profile';;
        esac;;

status)
        case "$prev" in
            status)
                completions='';;
            
            *)
                completions='--csv --c --decode_uris --d --long --l --relative_dates --a -H --host --color -U --no-ssl -P --profile';;
        esac;;

timeline)
        case "$prev" in
            timeline)
                completions='';;
            
            *)
                completions='--csv --c --decode_uris --d --exclude --e --id --i --long --l --max_id --m --number --n --relative_dates --a --reverse --r --since_id --s -H --host --color -U --no-ssl -P --profile';;
        esac;;

trends)
        case "$prev" in
            trends)
                completions='';;
            
            *)
                completions='--exclude-hashtags --x -H --host --color -U --no-ssl -P --profile';;
        esac;;

trend_locations)
        case "$prev" in
            trend_locations)
                completions='';;
            
            *)
                completions='--csv --c --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host --color -U --no-ssl -P --profile';;
        esac;;

unfollow)
        case "$prev" in
            unfollow)
                completions='';;
            
            *)
                completions='--id --i -H --host --color -U --no-ssl -P --profile';;
        esac;;

update)
        case "$prev" in
            update)
                completions='';;
            
            *)
                completions='--location --l --file --f -H --host --color -U --no-ssl -P --profile';;
        esac;;

users)
        case "$prev" in
            users)
                completions='';;
            
            *)
                completions='--csv --c --id --i --long --l --relative_dates --a --reverse --r --sort --s --unsorted --u -H --host --color -U --no-ssl -P --profile';;
        esac;;

version)
        case "$prev" in
            version)
                completions='';;
            
            *)
                completions='-H --host --color -U --no-ssl -P --profile';;
        esac;;

whois)
        case "$prev" in
            whois)
                completions='';;
            
            *)
                completions='--csv --c --decode_uris --d --id --i --long --l --relative_dates --a -H --host --color -U --no-ssl -P --profile';;
        esac;;

whoami)
        case "$prev" in
            whoami)
                completions='';;
            
            *)
                completions='--csv --c --decode_uris --d --long --l --relative_dates --a -H --host --color -U --no-ssl -P --profile';;
        esac;;

delete)
        case "$prev" in
            delete)
                completions='block dm favorite list status help';;
            block)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
dm)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
favorite)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
list)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
status)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
help)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
            *)
                completions='-H --host --color -U --no-ssl -P --profile';;
        esac;;

list)
        case "$prev" in
            list)
                completions='add create information members remove timeline help';;
            add)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
create)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
information)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
members)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
remove)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
timeline)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
help)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
            *)
                completions='-H --host --color -U --no-ssl -P --profile';;
        esac;;

search)
        case "$prev" in
            search)
                completions='all favorites list mentions retweets timeline users help';;
            all)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
favorites)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
list)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
mentions)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
retweets)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
timeline)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
users)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
help)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
            *)
                completions='-H --host --color -U --no-ssl -P --profile';;
        esac;;

set)
        case "$prev" in
            set)
                completions='active bio language location name profile_background_image profile_image website help';;
            active)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
bio)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
language)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
location)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
name)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
profile_background_image)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
profile_image)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
website)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
help)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
            *)
                completions='-H --host --color -U --no-ssl -P --profile';;
        esac;;

stream)
        case "$prev" in
            stream)
                completions='all list matrix search timeline users help';;
            all)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
list)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
matrix)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
search)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
timeline)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
users)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
help)
		completions='-H --host --color -U --no-ssl -P --profile'
		;;
            *)
                completions='-H --host --color -U --no-ssl -P --profile';;
        esac;;

        *)
        completions="$COMMANDS"
        ;;
      esac

      COMPREPLY=( $( compgen -W "$completions" -- $cur ))
      return 0

    }

    complete -F _t $filenames t
    
