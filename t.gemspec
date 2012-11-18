# encoding: utf-8
require File.expand_path("../lib/t/version", __FILE__)

Gem::Specification.new do |spec|
  spec.add_dependency 'launchy', '~> 2.0'
  spec.add_dependency 'fastercsv', '~> 1.5'
  spec.add_dependency 'geokit', '~> 1.6'
  spec.add_dependency 'htmlentities', '~> 4.3'
  spec.add_dependency 'oauth', '~> 0.4'
  spec.add_dependency 'oj', '~> 1.4'
  spec.add_dependency 'retryable', '~> 1.2'
  spec.add_dependency 'thor', ['>= 0.16', '< 2']
  spec.add_dependency 'tweetstream', '~> 2.3'
  spec.add_dependency 'twitter', '~> 4.2'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'webmock'
  spec.author = "Erik Michaels-Ober"
  spec.bindir = 'bin'
  spec.description = %q{A command-line power tool for Twitter.}
  spec.email = 'sferik@gmail.com'
  spec.executables = %w(t)
  spec.files = %w(LICENSE.md README.md Rakefile t.gemspec)
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("bin/**/*")
  spec.files += Dir.glob("spec/**/*")
  spec.homepage = 'http://sferik.github.com/t/'
  spec.licenses = ['MIT']
  spec.name = 't'
  spec.require_paths = ['lib']
  spec.required_rubygems_version = Gem::Requirement.new(">= 1.3.6")
  spec.summary = %q{CLI for Twitter}
  spec.test_files = Dir.glob("spec/**/*")
  spec.version = T::Version.to_s
end
