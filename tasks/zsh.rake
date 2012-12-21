
namespace :completion do
  desc 'Generate zsh completion file'
  task :zsh do

    Bundler.require(:default)

    template_path = File.expand_path(File.join('etc', 't-completion.zsh'))
    File.open(template_path, 'w') { |f| f.write zsh_completion }
  end
end

def zsh_completion
%Q(#compdef t

# Completion for Zsh. Source from somewhere in your $fpath

_t (){
  local -a t_general_options

  #{general_options_completions}

  if (( CURRENT > 2 )); then
    (( CURRENT-- ))
    shift words
    _call_function 1 _t_${words[1]}
  else
    _values "t command" \\
#{task_completions}

  fi
}

#{command_functions}

#{subcommand_arguments_functions}

#{subcommand_functions}
)
end

def general_options_completions
%Q(t_general_options=("(-H --host)"{-H,--host=HOST}"[Twitter API server]"
    "(-N --no-color)"{-N,--no-color}"[Disable colorization in output]"
    "(-U --no-ssl)"{-U,--no-ssl}"[Disable SSL]"
    "(-P --profile)"{-P,--profile=FILE}"[Path to RC file]"
    $nul_arg
  )
)
end

def option_completion(thor_option)
  aliases = thor_option.aliases
  name = thor_option.name
  desc = thor_option.description.to_s.gsub "'", "\\\\'"
%Q("(#{aliases.join(' ')} --#{name})"{#{aliases.join(',')},--#{name}}"[#{desc}]" \\)

end

def command_function_arguments(command)
  body = command.options.map {|name, option | option_completion(option) }
  body << "$t_general_options && ret=0"

  body.join("\n    ")
end

def task_completions
  T::CLI.tasks.map(&:last).map do |task|
    desc = task.description.to_s.gsub "'", "\\\\'"
    %Q(      \"#{task.name}[#{desc}]\" \\)
  end.join("\n")
end

def commands
  T::CLI.tasks.
    reject {|name, task| T::CLI.subcommands.include?(name) }.
    map(&:last)
end

def command_function(command)
  func = %Q(_t_#{command.name}() {
  _arguments \\
    #{ command_function_arguments(command) }
}
)
end

def command_functions
  commands.
    map {|t| command_function(t) }.
    join("\n")
end

def subcommands
  T::CLI.tasks.
    select {|name, task| T::CLI.subcommands.include?(name) }.
    map(&:last)
end

def subcommand_function(command)
  func = %Q(_t_#{command.name}() {
  _arguments \\
    ":argument:__t_#{command.name}_arguments" \\
    $t_general_options && ret=0
}
)
end

def subcommand_functions
  subcommands.
    map {|t| subcommand_function(t) }.
    join("\n")
end

def arguments_function(subcommand)
  klass = T.const_get subcommand.name.capitalize
%Q(__t_#{subcommand.name}_arguments() {
  _args=(#{klass.tasks.map {|t| t.last.name }.join("\n    ") }
  )
  compadd "$@" -k _args
}
)
end

def subcommand_arguments_functions
  subcommands.map {|s| arguments_function(s) }.join("\n")
end
