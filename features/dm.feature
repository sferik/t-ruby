Feature: An user can send a direct message

  Scenario: Send direct message
    When I send the message "Testing" to "testcli2"
    Then the stdout should contain "Direct Message sent to @testcli2"
    And the exit status should be 0
