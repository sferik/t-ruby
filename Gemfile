source 'https://rubygems.org'

gem 'rake'
gem 'jruby-openssl', platforms: :jruby

group :development do
  gem 'pry'
  gem 'pry-debugger', platforms: :mri_19
end

group :test do
  gem 'coveralls', require: false
  gem 'nyan-cat-formatter'
  gem 'rspec', '>= 2.11'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'webmock', '>= 1.10.1'
end

gemspec
