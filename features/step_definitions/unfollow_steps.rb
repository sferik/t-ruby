When /^I unfollow "([^"]*)" using an authorized profile$/ do |username|
  steps "When I run `t unfollow #{username} --profile #{File.expand_path('../../fixtures/.trc', __FILE__)}`"
end
