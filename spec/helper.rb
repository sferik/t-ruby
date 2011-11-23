major, minor, patch = RUBY_VERSION.split('.')
$KCODE = 'u' if major.to_i == 1 && minor.to_i < 9
require 'simplecov'
SimpleCov.start
require 't'
require 'rspec'
require 'webmock/rspec'
