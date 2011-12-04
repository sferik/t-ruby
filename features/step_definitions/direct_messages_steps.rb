When /^I list my direct messages using an authorized profile$/ do
  steps "When I run `t direct_messages --profile #{File.expand_path('../../fixtures/.trc', __FILE__)}`"
end
