require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

import 'tasks/zsh.rake'

task :release => 'completion:zsh'
task :test => :spec
task :default => :spec
