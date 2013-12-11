require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

begin
  require 'rubocop/rake_task'
  Rubocop::RakeTask.new
rescue LoadError
  desc 'Run RuboCop'
  task :rubocop do
    $stderr.puts 'Rubocop is disabled'
  end
end

Dir.glob('tasks/*.rake').each { |r| import r }

task :release => 'completion:zsh'
task :test => :spec
task :default => [:spec, :rubocop]
