unless ENV['CI']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'spec'
  end
end

ENV['THOR_COLUMNS'] = "80"

require 't'
require 'rspec'
require 'timecop'
require 'webmock/rspec'

def a_delete(path, endpoint='https://api.twitter.com')
  a_request(:delete, endpoint + path)
end

def a_get(path, endpoint='https://api.twitter.com')
  a_request(:get, endpoint + path)
end

def a_post(path, endpoint='https://api.twitter.com')
  a_request(:post, endpoint + path)
end

def a_put(path, endpoint='https://api.twitter.com')
  a_request(:put, endpoint + path)
end

def stub_delete(path, endpoint='https://api.twitter.com')
  stub_request(:delete, endpoint + path)
end

def stub_get(path, endpoint='https://api.twitter.com')
  stub_request(:get, endpoint + path)
end

def stub_post(path, endpoint='https://api.twitter.com')
  stub_request(:post, endpoint + path)
end

def stub_put(path, endpoint='https://api.twitter.com')
  stub_request(:put, endpoint + path)
end

def project_path
  File.expand_path("../..", __FILE__)
end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end
