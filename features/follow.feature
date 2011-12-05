Feature: A user can follow an account

  Scenario: Follow an account
    When I follow "sferik" using an authorized profile
    Then the stdout should contain "You're now following @sferik."
    And the exit status should be 0
