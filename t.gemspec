# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 't/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'launchy', '~> 2.4'
  spec.add_dependency 'geokit', ['>= 1.8.3', '< 2']
  spec.add_dependency 'htmlentities', '~> 4.3'
  spec.add_dependency 'oauth', '~> 0.4.7'
  spec.add_dependency 'retryable', '~> 1.3'
  spec.add_dependency 'thor', ['>= 0.18.1', '< 2']
  spec.add_dependency 'twitter', '~> 5.5'
  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.author = 'Erik Michaels-Ober'
  spec.bindir = 'bin'
  spec.cert_chain = %w[certs/sferik.pem]
  spec.description = %q{A command-line power tool for Twitter.}
  spec.email = 'sferik@gmail.com'
  spec.executables = %w[t]
  spec.files = %w[CONTRIBUTING.md LICENSE.md README.md Rakefile t.gemspec]
  spec.files += Dir.glob('lib/**/*.rb')
  spec.files += Dir.glob('bin/**/*')
  spec.files += Dir.glob('spec/**/*')
  spec.homepage = 'http://sferik.github.com/t/'
  spec.licenses = %w[MIT]
  spec.name = 't'
  spec.require_paths = %w[lib]
  spec.required_ruby_version = '>= 1.9.2'
  spec.required_rubygems_version = '>= 1.3.5'
  spec.signing_key = File.expand_path('~/.gem/private_key.pem') if $PROGRAM_NAME =~ /gem\z/
  spec.summary = %q{CLI for Twitter}
  spec.test_files = Dir.glob('spec/**/*')
  spec.version = T::Version
end
