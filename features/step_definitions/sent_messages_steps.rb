When /^I list my sent messages using an authorized profile$/ do
  steps "When I run `t sent_messages --profile #{File.expand_path('../../fixtures/.trc', __FILE__)}`"
end
