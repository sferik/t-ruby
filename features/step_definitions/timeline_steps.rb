When /^I list my timeline using an authorized profile$/ do
  steps "When I run `t timeline --profile #{File.expand_path('../../fixtures/.trc', __FILE__)}`"
end
