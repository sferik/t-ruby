Feature: A user can follow an account

  Scenario: Follow an account
    When I follow "testcli2" using an authorized profile
    Then the stdout should contain "You're now following @testcli2."
    And the exit status should be 0
