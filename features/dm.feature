Feature: An user can send a direct message

  Scenario: Send direct message
    When I send the message "Testing" to "testcli2" using an authorized profile
    Then the stdout should contain "Direct Message sent to @testcli2"
    And the exit status should be 0

  Scenario: Send direct message
    When I send the message "Testing" to "sferik" using an authorized profile
    Then the stdout should not contain "Direct Message sent to @sferik"
    Then the stderr should contain "You cannot send messages to users who are not following you."
