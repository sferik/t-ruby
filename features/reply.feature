Feature: A user can reply to a status

  Scenario: Successful reply
    When I reply "Testing" to "testcli2" using an authorized profile
    Then the stdout should contain "Reply created"
    And the exit status should be 0

  Scenario: Unsuccessful reply
    When I reply "Testing" to "testcli2" using an unauthorized profile
    Then the stdout should not contain "Reply created"
    And the stderr should contain "Could not authenticate you."
    And the exit status should not be 0
