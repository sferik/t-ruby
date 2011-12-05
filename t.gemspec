# encoding: utf-8
require File.expand_path("../lib/t/version", __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency 'actionpack', '~> 3.1'
  gem.add_dependency 'launchy', '~> 2.0'
  gem.add_dependency 'geokit', '~> 1.6'
  gem.add_dependency 'oauth', '~> 0.4'
  gem.add_dependency 'thor', '~> 0.15.0.rc2'
  gem.add_dependency 'twitter', ['~> 2.0', '>= 2.0.1']
  gem.add_dependency 'yajl-ruby', '~> 1.1'
  gem.add_development_dependency 'aruba'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'webmock'
  gem.author = "Erik Michaels-Ober"
  gem.bindir = 'bin'
  gem.description = %q{A command-line interface for Twitter.}
  gem.email = 'sferik@gmail.com'
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files = `git ls-files`.split("\n")
  gem.homepage = 'http://github.com/sferik/t'
  gem.name = 't'
  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if gem.respond_to? :required_rubygems_version=
  gem.summary = %q{CLI for Twitter}
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.version = T::Version.to_s
end
