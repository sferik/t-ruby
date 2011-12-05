When /^I get profile information for "([^"]*)"$/ do |username|
  steps "When I run `t whois #{username}`"
end
