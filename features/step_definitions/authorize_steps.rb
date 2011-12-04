When /^I authorize my account$/ do
  rcfile = RCFile.instance
  rcfile.path = File.expand_path('../../fixtures/.trc', __FILE__)
  profile = rcfile["testcli"]["MYCm5oNXkmaAPachb5HBhw"]
  steps %{
    When I run `t authorize --consumer-key #{profile["consumer_key"]} --consumer_secret #{profile["consumer_secret"]} --dry-run` interactively
    And I type ""
  }
end
