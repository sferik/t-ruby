source 'https://rubygems.org'

gem 'rake'
gem 'jruby-openssl', platforms: :jruby

group :development do
  gem 'pry'
  platforms :ruby_19, :ruby_20 do
    gem 'pry-debugger'
    gem 'pry-stack_explorer'
  end
end

group :test do
  gem 'coveralls'
  gem 'rspec', '>= 3'
  gem 'rubocop', :github => 'bbatsov/rubocop', :ref => '90bc9d4' 
  gem 'simplecov', '>= 0.9'
  gem 'timecop'
  gem 'webmock', '>= 1.10.1'
end

gemspec
