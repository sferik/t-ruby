Feature: A user can unfollow an account

  Scenario: Unfollow an account
    When I unfollow "sferik" using an authorized profile
    Then the stdout should contain "You are no longer following @sferik."
    And the exit status should be 0
