# encoding: utf-8
require File.expand_path("../lib/t/version", __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency 'activesupport', ['>= 2.3.11', '< 4']
  gem.add_dependency 'launchy', '~> 2.0'
  gem.add_dependency 'fastercsv', '~> 1.5'
  gem.add_dependency 'geokit', '~> 1.6'
  gem.add_dependency 'htmlentities', '~> 4.3'
  gem.add_dependency 'json', '~> 1.6'
  gem.add_dependency 'oauth', '~> 0.4'
  gem.add_dependency 'retryable', '~> 1.2'
  gem.add_dependency 'thor', ['>= 0.15.2', '< 2']
  gem.add_dependency 'tweetstream', '~> 1.1'
  gem.add_dependency 'twitter', '~> 2.4'
  gem.add_dependency 'twitter-text', '~> 1.4'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'timecop'
  gem.add_development_dependency 'webmock'
  gem.author = "Erik Michaels-Ober"
  gem.bindir = 'bin'
  gem.description = %q{A command-line power tool for Twitter.}
  gem.email = 'sferik@gmail.com'
  gem.executables = %w(t)
  gem.files = %w(LICENSE.md README.md Rakefile t.gemspec)
  gem.files += Dir.glob("lib/**/*.rb")
  gem.files += Dir.glob("bin/**/*")
  gem.files += Dir.glob("spec/**/*")
  gem.homepage = 'http://sferik.github.com/t/'
  gem.name = 't'
  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if gem.respond_to? :required_rubygems_version=
  gem.summary = %q{CLI for Twitter}
  gem.test_files = Dir.glob("spec/**/*")
  gem.version = T::Version.to_s
end
