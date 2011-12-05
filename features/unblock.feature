Feature: A user can unblock an account

  Scenario: Unlock account
    When I unblock "spam"
    Then the stdout should contain "Unblocked @spam"
    And the exit status should be 0
