require 'aruba/cucumber'
require 't'

ENV['PATH'] = "#{File.expand_path('../../../bin', __FILE__)}#{File::PATH_SEPARATOR}#{ENV['PATH']}"

Before do
  @aruba_timeout_seconds = 5
end
