Feature: A user can list his or her mentions

  Scenario: List mentions
    When I list mentions using an authorized profile
    Then the stdout should contain "sferik: @testcli Testing"
    And the exit status should be 0
