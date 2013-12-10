source 'https://rubygems.org'

gem 'rake'
gem 'jruby-openssl', :platforms => :jruby

group :development do
  gem 'guard-rspec'
  gem 'pry'
  gem 'pry-debugger', :platforms => :mri_19
end

group :test do
  gem 'coveralls', :require => false
  gem 'rspec', '>= 2.14'
  gem 'simplecov', :require => false
  gem 'timecop'
  gem 'webmock', '>= 1.10.1'
end

platforms :rbx do
  gem 'rubinius-coverage', '~> 2.0'
  gem 'rubysl-base64', '~> 2.0'
  gem 'rubysl-bigdecimal', '~> 2.0'
  gem 'rubysl-coverage', '~> 2.0'
  gem 'rubysl-csv', '~> 2.0'
  gem 'rubysl-ipaddr', '~> 2.0'
  gem 'rubysl-logger', '~> 2.0'
  gem 'rubysl-rexml', '~> 2.0'
  gem 'rubysl-singleton', '~> 2.0'
end

gemspec
