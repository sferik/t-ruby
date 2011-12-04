When /^I unblock "([^"]*)"$/ do |username|
  steps "When I run `t unblock #{username} --profile #{File.expand_path('../../fixtures/.trc', __FILE__)}`"
end
