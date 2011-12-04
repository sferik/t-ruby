When /^I list my accounts using an authenticated profile$/ do
  steps "When I run `t accounts -P #{File.expand_path('../../fixtures/.trc', __FILE__)}`"
end
