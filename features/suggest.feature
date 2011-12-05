Feature: A user can get a list of suggested accounts

  Scenario: Get suggested accounts
    When I get suggestions for an authorized profile
    Then the stdout should contain "Try following "
    And the exit status should be 0
