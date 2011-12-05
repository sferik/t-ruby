When /^I reply "([^"]*)" to "([^"]*)" using an authorized profile$/ do |message, username|
  # Append a random number to the end of the tweet to avoid duplicate status errors on successive test runs
  steps "When I run `t reply #{username} '#{message} #{rand(2**100)}' --profile #{File.expand_path('../../fixtures/.trc', __FILE__)}`"
end

When /^I reply "([^"]*)" to "([^"]*)" using an unauthorized profile$/ do |message, username|
  steps "When I run `t reply #{username} '#{message} #{rand(2**100)}' --profile /tmp/.trc`"
end
