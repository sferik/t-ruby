Feature: A user can open an account

  Scenario: Open account
    When I open "sferik"
    Then the stdout should contain "https://twitter.com/sferik"
    And the exit status should be 0
