Feature: An user can block an account

  Scenario: Block account
    When I block "spam"
    Then the stdout should contain "Blocked @spam"
    And the exit status should be 0
