When /^I follow "([^"]*)" using an authorized profile$/ do |username|
  steps "When I run `t follow #{username} --profile #{File.expand_path('../../fixtures/.trc', __FILE__)}`"
end
