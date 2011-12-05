When /^I retweet the latest Tweet by "([^"]*)" using an authorized profile$/ do |username|
  steps "When I run `t retweet #{username} --profile #{File.expand_path('../../fixtures/.trc', __FILE__)}`"
end
