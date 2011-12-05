When /^I get suggestions for an authorized profile$/ do
  steps "When I run `t suggest --profile #{File.expand_path('../../fixtures/.trc', __FILE__)}`"
end
