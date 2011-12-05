When /^I update my status to "([^"]*)" using an authorized profile$/ do |message|
  # Append a random number to the end of the tweet to avoid duplicate status errors on successive test runs
  steps "When I run `t update '#{message} #{rand(2**100)}' --profile #{File.expand_path('../../fixtures/.trc', __FILE__)}`"
end

When /^I update my status to "([^"]*)" using an unauthorized profile$/ do |message|
  steps "When I run `t update '#{message} #{rand(2**100)}' --profile /tmp/.trc`"
end
