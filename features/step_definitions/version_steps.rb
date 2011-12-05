When /^I get the gem version$/ do
  steps "When I run `t version`"
end

Then /^the stdout should contain a gem version$/ do
  steps %{
    Then the stdout should contain exactly:
    """
    #{T::Version}

    """
  }
end
