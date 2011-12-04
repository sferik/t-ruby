When /^I block "([^"]*)"$/ do |username|
  steps %(When I run `t block #{username} --profile #{File.expand_path('../../fixtures/.trc', __FILE__)}`)
end
