source 'https://rubygems.org'

gem 'rake'
gem 'twitter', :git => 'https://github.com/sferik/twitter.git', :branch => 'http'
gem 'http', :git => 'https://github.com/tarcieri/http.git'
gem 'jruby-openssl', :platforms => :jruby

group :development do
  gem 'guard-rspec'
  gem 'pry'
  platforms :ruby_19, :ruby_20 do
    gem 'pry-debugger'
    gem 'pry-stack_explorer'
  end
end

group :test do
  gem 'coveralls', :require => false
  gem 'rspec', '>= 2.14'
  gem 'rubocop', '>= 0.19', :platforms => [:ruby_19, :ruby_20, :ruby_21]
  gem 'simplecov', :require => false
  gem 'timecop'
  gem 'webmock', '>= 1.10.1'
end

gemspec
