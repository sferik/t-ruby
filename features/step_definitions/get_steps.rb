When /^I get "([^"]*)"$/ do |username|
  steps "When I run `t get #{username}`"
end
