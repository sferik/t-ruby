source 'https://rubygems.org'

gem 'rake'
gem 'jruby-openssl', :platforms => :jruby

group :development do
  gem 'pry'
  gem 'pry-debugger', :platforms => :mri_19
end

group :test do
  gem 'coveralls', :require => false
  gem 'rspec', '>= 2.14'
  gem 'cucumber'
  gem 'simplecov', :require => false
  gem 'timecop'
  gem 'webmock', '>= 1.10.1'
  gem 'vcr'
  gem 'guard-rspec'
end

gemspec
