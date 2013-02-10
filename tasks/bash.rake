
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
  topcmd=${COMP_WORDS[1]}
  prev=${COMP_WORDS[COMP_CWORD-1]}

  COMMANDS='#{commands.map(&:name).join(' ')}'

  case "$topcmd" in
    #{comp_cases}
    *)
    completions="$COMMANDS"
    ;;
  esac

  COMPREPLY=( $( compgen -W "$completions" -- $cur ))
  return 0

}

[ -n "${have:-}" ] && complete -F _t $filenames t
]

end

def comp_cases

    commands.map do |cmd|

        options_str = options(cmd).join(' ')
        subcmds = subcommands(cmd)

        subcommands_cases = subcmds.map do |sn|

            "#{sn})\n\t\tcompletions='#{options_str}'\n\t\t;;"

        end.join("\n")


        %Q[#{cmd.name})
    case "$prev" in
        #{cmd.name})
            completions='#{subcmds.join(' ')}';;
        #{subcommands_cases}
        *)
            completions='#{options_str}';;
    esac;;\n]

    end

end

def options(cmd)

    cmd.options.map(&:last).map do |o|

        if o.aliases
            "--#{o.name} #{o.aliases.map{ |a| '-' + a }.join(' ')}"
        else
            "--#{o.name}"
        end

    end.concat(global_options)

end

def commands
    T::CLI.tasks.map(&:last)
end

def global_options
  %w(-H --host --color -U --no-ssl -P --profile)
end

def subcommands(cmd=nil)

    return [] unless T::CLI.subcommands.include?(cmd.name)

    klass = T.const_get cmd.name.capitalize

    klass.tasks.map(&:last).map(&:name)

end
