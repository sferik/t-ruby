
namespace :completion do
  desc 'Generate bash completion file'
  task :bash do

    Bundler.require(:default)

    output_path = 'etc/t-completion.sh'
    file_path = File.expand_path(output_path)
    puts "Compiling bash completion to #{output_path}"
    File.open(file_path, 'w') { |f| f.write bash_completion }

#    git_status = %x[git status -s]
#    if !!git_status[%r{M #{output_path}}]
#      cmd = "git add #{output_path} && git commit -m 'Updating Bash completion'"
#      result = system cmd
#      fail "Could not commit changes" unless result
#    end
  end
end

def bash_completion
%Q[# Completion for Bash. Copy it in /etc/bash_completion.d/ or source it
# somewhere in your ~/.bashrc

_t() {

  local cur prev completions

  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}

  COMMANDS='#{commands}'
  GLOBAL_OPTS='#{global_options}'

  case "${prev}" in
    #{case_commands_options}
    *)
    completions="$COMMANDS"
    ;;
  esac

    COMPREPLY=( $( compgen -W "$GLOBAL_OPTS $completions" -- $cur ))
    return 0

}

[ -n "${have:-}" ] && complete -F _t $filenames t
]

end

def commands
    T::CLI.tasks.map(&:last).map(&:name).join ' '
end

def global_options
  '-H --host --color -U --no-ssl -P --profile'
end

def case_command_options(cmd)

    options = cmd.options.map(&:last).map do |o|

        if o.aliases
            "--#{o.name} #{o.aliases.map{ |a| '-' + a }.join(' ')}"
        else
            "--#{o.name}"
        end

    end.join(' ')

    "\t#{cmd.name})\n\t\tcompletions='#{options}'\n\t\t;;"
end

def case_commands_options
    T::CLI.tasks.map(&:last).map do |c|
        case_command_options(c)
    end.join("\n")
end
