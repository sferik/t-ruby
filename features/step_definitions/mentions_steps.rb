When /^I list my mentions using an authorized profile$/ do
  steps "When I run `t mentions --profile #{File.expand_path('../../fixtures/.trc', __FILE__)}`"
end
