require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

Dir.glob('tasks/*.rake').each { |r| import r }

task :release => 'completion:zsh'
task :release => 'completion:bash'
task :test => :spec
task :default => :spec
