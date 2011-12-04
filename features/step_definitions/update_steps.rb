When /^I update my status using an authenticated profile$/ do
  # Add a random number to the end of the tweet to avoid duplicate status errors on successive test runs
  steps "When I run `t update -P #{File.expand_path('../../fixtures/.trc', __FILE__)} 'Testing #{rand(2**100)}'`"
end

When /^I update my status using an unauthenticated profile$/ do
  steps "When I run `t update -P /tmp/.trc 'Testing #{rand(2**100)}'`"
end
