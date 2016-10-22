source 'https://rubygems.org'

gem 'rake'
gem 'jruby-openssl', platforms: :jruby

group :development do
  gem 'pry'
  platforms :ruby_19 do
    gem 'pry-debugger'
    gem 'pry-stack_explorer'
  end
  platforms :ruby_20 do
    gem 'pry-byebug'
    gem 'pry-stack_explorer'
  end
end

group :test do
  gem 'coveralls'
  gem 'rspec', '>= 3'
  gem 'rubocop', '>= 0.37'
  gem 'simplecov', '>= 0.9'
  gem 'timecop'
  gem 'tins', '~> 1.6.0', platforms: :ruby_19
  gem 'webmock', '>= 1.10.1'
end

gemspec
