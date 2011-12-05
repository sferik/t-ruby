When /^I get stats for "([^"]*)"$/ do |username|
  steps "When I run `t stats #{username}`"
end
