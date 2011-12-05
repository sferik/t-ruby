When /^I open "([^"]*)"$/ do |username|
  steps "When I run `t open #{username} --dry-run`"
end
