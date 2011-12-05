When /^I send the message "([^"]*)" to "([^"]*)" using an authorized profile$/ do |text, username|
  # Append a random number to the end of the message to avoid duplicate status errors on successive test runs
  steps "When I run `t dm #{username} '#{text} #{rand(2**100)}' --profile #{File.expand_path('../../fixtures/.trc', __FILE__)}`"
end
