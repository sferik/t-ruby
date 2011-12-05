Feature: A user can update his or her status

  Scenario: Successful Tweet
    When I update my status to "Testing" using an authorized profile
    Then the stdout should contain "Tweet created"
    And the exit status should be 0

  Scenario: Unsuccessful Tweet
    When I update my status to "Testing" using an unauthorized profile
    Then the stdout should not contain "Tweet created"
    And the stderr should contain "Could not authenticate you."
    And the exit status should not be 0
